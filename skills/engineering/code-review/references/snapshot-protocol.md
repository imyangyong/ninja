# Snapshot Protocol

使用本协议选择唯一 scope、捕获可复现内容，并生成 canonical fingerprint。

## Scope modes

| Mode | 输入 | Result snapshot |
|:-|:-|:-|
| `committed-range` | base ref 与可选 result ref，或单个待审 commit | merge-base OID、result OID、diff 与 result blobs |
| `staged` | 明确的 staged 请求 | index entries、index blobs 与 diff |
| `worktree` | 明确的 worktree 请求 | tracked、untracked、deleted entries 的 filesystem/index 内容 |
| `files` | 明确 paths | 展开后的精确 path 集合与当前内容 |
| `snippet` | 用户消息中的代码 | 原始代码和消息内标识 |
| `patch` | 用户提供的 diff/patch 内容或文件 | 原始 patch bytes、可解析 entries，以及可取得的 preimage/result 内容 |
| `pr` | provider 的 PR 标识 | provider 给出的 base/head OID、diff 与 head 内容 |

`committed-range` 将 refs 解析为 OID。用户给出 base 时，result 默认为捕获时的 `HEAD` OID；diff 使用 merge-base 到 result OID。用户明确要求审查单个 commit `X` 时，`X` 是 result，普通 commit 的 base 是其唯一 parent；merge commit 必须由用户指定 parent，不能默认选 first parent。PR provider 不可用时请求 base ref 或原始 diff。

`worktree` 同时读取 status、tracked diff 和 untracked paths。`git diff HEAD` 不能单独代表 worktree scope。

`patch` 不猜测缺失上下文。patch 未包含完整 result 内容、preimage 或 binary payload 时，将对应 locator 设为 `null` 并记录 limitation；只有用户提供或仓库中可与 patch identity 验证匹配的内容才能补入 snapshot。无法解析至少一个 entry 的 patch 是无效 scope；请求有效 patch，或由用户明确改为 `snippet`。

## Captured diff bytes

所有 Git 命令从 repo root 运行。`committed-range`、`staged` 与 `worktree` 的 tracked 部分使用以下固定 diff 选项，保留 stdout 原始 bytes，不做终端解码、换行或路径转换：

```text
git -c core.quotePath=false -c diff.algorithm=myers diff \
  --binary --full-index --no-color --no-ext-diff --no-textconv \
  --no-indent-heuristic --no-renames --submodule=short \
  --src-prefix=a/ --dst-prefix=b/
```

- `committed-range` 追加 `<merge-base OID> <result OID> --`；`staged` 在 `diff` 后加入 `--cached` 并在末尾追加 `--`；`worktree` 追加 `HEAD --`。
- `worktree` 再按 Fingerprint 节规定的 entry 顺序，为每个 untracked path 运行同组选项的 `git diff --no-index -- /dev/null <path>`；exit code 1 表示成功产生差异。将 tracked stdout 与各 untracked stdout 不加分隔符依次拼接。
- `patch` 使用原始 patch bytes；`pr` 使用记录 provider version 的原始 diff bytes；`files` 与 `snippet` 使用零长度 bytes。

`captured_diff.locator` 必须解析为上述最终 byte stream，`captured_diff.sha256` 直接对该 stream 计算。命令不可用或无法捕获原始 bytes 时记录 limitation，不用近似输出冒充 canonical diff。

## Canonical scope ledger

使用以下字段；不适用的单值字段写 `null`，集合写空数组：

```yaml
schema_version: 1
mode: committed-range | staged | worktree | files | snippet | patch | pr
user_declaration: <原始范围声明>
base_oid: <OID|null>
merge_base_oid: <OID|null>
result_oid: <OID|null>
captured_diff:
  locator: <inline:key|provider:id|artifact:absolute-path|null>
  sha256: <64 lowercase hex>
entries:
  - path: <repo-relative POSIX path or snippet ID>
    status: provided | untracked | added | modified | deleted | renamed | copied | mode-changed | unmerged
    old_path: <repo-relative path|null>
    source: commit | index | filesystem | message | provider | artifact
    content_locator: <inline:key|git:blob-OID|filesystem:absolute-path|readlink:absolute-path|provider:id|artifact:absolute-path|null>
    content_sha256: <hex|null>
    preimage_locator: <inline:key|git:blob-OID|provider:id|artifact:absolute-path|null>
    preimage_sha256: <hex|null>
    mode: <git mode|string|null>
    object_oid: <blob/submodule OID|null>
    kind: text | binary | symlink | submodule | generated | unknown
    readable: <boolean>
    limitation: <string|null>
fingerprint:
  algorithm: sha256-rfc8785-v1
  value: <64 lowercase hex>
```

`files` 与 `snippet` 使用 `provided`；worktree 中未被 index 跟踪的 path 使用 `untracked`；其余 entry 使用 patch 或版本控制语义的 status。一个审查对象使用一个 entry：rename/copy 通过 `old_path` 表示；删除项使用 preimage；symlink hash link target；submodule 记录 object OID；mode-only change 保留 content hash 并记录新 mode。unmerged entry 不能形成确定性 result snapshot，记录限制并停止对应裁决。

没有独立 diff 的 `files` 与 `snippet` 使用 `captured_diff.locator: null`，并将 `captured_diff.sha256` 设为零长度 bytes 的 SHA-256。`patch` 必须保存原始 patch locator 与 hash。

locator 是可解析标识，不是类型名：`inline:key` 指向派发 payload 中的唯一 key；`readlink:absolute-path` 读取 symlink 自身未经换行转换的 link-target bytes，不跟随目标；其他前缀后的值必须足以读取对应内容。

## Fingerprint

构造只包含 `schema_version`、`mode`、OID 字段、`captured_diff.sha256`，以及每个 entry 的以下 snapshot 字段的 JSON：

`path`、`status`、`old_path`、`source`、`content_sha256`、`preimage_sha256`、`mode`、`object_oid`、`kind`

1. entry 按 path、status、old_path 的原始 UTF-8 bytes 依次作无符号字节序比较；`null` 排在任何字符串前；
2. 使用 RFC 8785 JSON Canonicalization Scheme 序列化整个对象；保留 schema 中显式的 `null` 和空数组，不接受等价但不同 bytes 的自定义 JSON 编码；
3. 对 canonical JSON 的 UTF-8 bytes 计算 SHA-256。

fingerprint 不包含 locator、readable、limitation、时间或绝对 workspace 路径。content hash 始终基于原始 bytes，不基于终端显示文本。

## Snapshot access

所有 reviewer 接收 fingerprint 的顶层输入、全部 entry snapshot fields 与 fingerprint value 组成的 identity projection；省略 `user_declaration`、locator、readable 与 limitation。Code Quality entry 以 `(path, status, old_path)` 作为 assigned key，只有 assigned entries 的 content/preimage/check locators 通过独立 raw evidence block 传递；Spec Compliance 接收完整 scope 的 raw evidence。

reviewer 必须能通过 `content_locator` 读取捕获内容：

- commit/index/provider 内容优先使用 immutable blob/OID 或 inline content；
- filesystem 内容使用绝对 artifact path 或原始 path 加派发 fingerprint；
- symlink 使用 immutable blob、`readlink:` locator 或保存 link-target 原始 bytes 的 inline/artifact locator，不能通过普通 filesystem read 跟随目标；
- deleted entry 使用 preimage；
- binary/generated/unreadable entry 保留可读来源、schema、manifest 或生成配置作为 evidence locator。

ledger 含 `index` 或 `filesystem` source 时，在派发前和聚合前重算 fingerprint；仅由 message、完整 OID 或 provider immutable version 构成的 snapshot 无需重算。检查或其他进程改变 mutable snapshot 时返回 stale，不把新旧内容混合。

## Integrity criteria

- 每个审查对象恰好有一个 entry，且 status/source 与 scope mode、实际来源一致；
- 每个 locator 可解析到与 hash 相符的内容，或有明确 limitation；
- 所有 refs 均已解析为 OID；
- changed、deleted、untracked、rename、mode、symlink 与 submodule 状态均未丢失；
- fingerprint 可从 ledger 独立重算。
