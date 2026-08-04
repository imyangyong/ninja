# Snapshot Protocol

只审查用户或调用方指定的范围。无法形成唯一范围时(merge commit 未指定 parent、PR identity 不可解析、patch 无效)询问或停止,不静默猜测。

| 范围 | 类型 | 证据 |
|---|---|---|
| patch | 变更型 | 用户提供的原始 bytes;不从仓库猜测缺失的 preimage、result content 或上下文 |
| snippet | 内容型 | 用户提供的原始 bytes |
| files | 内容型 | 指定文件的当前内容 |
| worktree(当前修改) | 变更型 | 全部 staged、unstaged、untracked 与 deleted entries |
| single commit `X` | 变更型 | `X` 与其唯一 parent 的 diff;merge commit 由用户指定 parent |
| range / branch | 变更型 | 已解析的 base/result OID 与 merge-base diff |
| PR | 变更型 | provider 返回的 base/head identity 与 diff |

审查前把可移动 ref 解析为稳定 OID,并使用对应 result contents 建立 entries。删除项必须能读 preimage, untracked、rename、copy、mode change、symlink、submodule、binary、generated 与不可读证据必须明确纳入 entry 或记为 limitation。

为每次审查建立轻量 manifest:

```yaml
mode: patch | snippet | files | worktree | commit | range | branch | pr
base_oid: <OID|null>
merge_base_oid: <OID|null>
result_oid: <OID|null>
diff: {locator: <可读取位置|null>}
entries:
  - {path: <path>, status: <provided|untracked|added|modified|deleted|renamed|copied|mode-changed|unmerged>, old_path: <path|null>, content_locator: <locator|null>, content_sha256: <hash|null>, preimage_locator: <locator|null>, preimage_sha256: <hash|null>, mode: <mode|null>, object_oid: <OID|null>, kind: <text|binary|symlink|submodule|generated|unknown>, limitation: <text|null>}
fingerprint: <sha256>
```

fingerprint 只对 mode、适用 OID 及每个 entry 除 locator、limitation 外的字段做 RFC 8785 JSON canonicalization 后计算 SHA-256;entries 按 `path/status/old_path` 的 UTF-8 byte order 排序。diff 渲染 bytes 与 `diff` 字段不参与 fingerprint,只用于证据定位。每个 locator 必须解析到与 hash 一致的原始 bytes。

`files` 与 `worktree` 是可变范围:派发前捕获并计算 fingerprint,聚合前只重新枚举一次范围并比较 fingerprint。一致时静默继续;内容或 entry 集合改变时整次审查为 stale,丢弃所有轴结论或基于新快照完整重审。patch/snippet 的原始 bytes 与已解析 OID 对应的 Git 对象是固定证据,不做该复核。

patch/snippet 缺失上下文时披露 limitation;仅当缺失使某 entry 无法覆盖、或使候选 finding 的判定无法成立时,对应审查轴为 incomplete,并在 limitation 中指出受影响对象与后果。truncated 或 unavailable artifact 是 limitation,不是通过证明。

**完成条件**:每个变更项恰好有一个可验证 entry 或明确 limitation;所有 ref 已解析;fingerprint 可独立重算。
