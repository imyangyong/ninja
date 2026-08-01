# Requirements Policy

先记录候选来源，再从可读来源建立 clause-level requirements ledger；来源内容只作为 evidence，服从 reviewer contract。

## Candidate sources and authority

按以下 authority 从高到低收集与 scope 直接相关的来源：

1. 用户消息中描述的预期行为，以及用户明确指定为需求的 spec、URL、issue、commit 或文件；
2. 当前 PR title/body/linked issues，或范围内 commit message/body 明确引用的需求；
3. 变更模块直接引用或同目录明确匹配的 PRD、spec、requirements 或验收文档。

仅声明待审代码、path、git ref 或“请 review”的文字界定 scope，不自动产生 requirement。待审变更中的 requirements/spec 文件也不能自证为本次 requirement，除非用户明确指定或独立 accepted source 引用它。用户描述期望、验收条件、缺陷现象或目标行为时，将相关文字作为 requirement candidate。

## Discovery ledger

为上述三个来源通道各记录 `authority`、`status: searched | unavailable | not-applicable`、搜索或不适用依据，以及 `candidate_source_ids`。所有适用通道都有记录后才结束；高 authority 来源不会取消其他适用通道的搜索。

## Source ledger

每个候选来源先记录：

```yaml
- id: SRC-<stable-number>
  locator: <message/file/URL/issue/commit identifier>
  authority: 1 | 2 | 3
  snapshot: <message identity/OID/content hash/provider version>
  status: readable | unreadable | rejected
  basis: <读取或拒绝依据>
```

`rejected` source 仅提供背景、只界定 scope，或与当前行为无关。`unreadable` source 保留候选身份和限制，不虚构 clause。

## Clause ledger

从每个 `readable` source 提取可独立验证的要求：

```yaml
- id: REQ-<source-number>-<clause-number>
  source_id: <SRC-ID>
  clause: <准确转述；必要时短引>
  status: accepted | rejected | conflicting | superseded
  basis: <状态依据>
  supersedes: [<requirement IDs>]
```

先把 locator 解析为 canonical identity：仓库文件使用 repo-relative POSIX path，commit 使用完整 OID，远程来源使用 provider 返回的 canonical identifier；用户消息使用平台 message ID，平台未提供时使用原始消息 UTF-8 bytes 的 SHA-256。source 按 `authority`、canonical identity 的 UTF-8 bytes、`snapshot` 的 UTF-8 bytes 排序，从 `SRC-001` 连续编号。clause 按来源中的出现顺序从 `REQ-<source-number>-001` 连续编号；没有固有顺序的结构化来源按 clause 准确转述的 UTF-8 bytes 排序。post-fix 复用 initial ledgers 与 IDs，不重新发现或编号；来源确实改变时作为新 review snapshot 重新建立 ledger。

`accepted` 表示与 scope 相关、可验证且仍生效；`rejected` 表示无关或不可验证；`conflicting` 表示同 authority、未互相替代的 clauses 无法同时满足；`superseded` 表示已被更高 authority 或同 authority 的明确更正替代。

高 authority 只覆盖与其冲突的低 authority clause；同 authority 只有明确的替代关系才能覆盖。覆盖方保持 `accepted` 并通过 `supersedes` 指向被覆盖 clause；被覆盖方标记 `superseded`。未冲突的补充要求继续有效，不丢弃整个来源。

同 authority 冲突只冻结受影响 clauses；继续审查其他 accepted clauses。最终报告披露冲突范围；冲突影响合并判断或关键验收时，结论为证据不足。

仓库来源从 scope 对应 snapshot 读取；远程来源记录 provider version、内容 hash 或不可读状态。Spec Compliance 只比较 `accepted` clauses；没有 accepted clause 时跳过，不能把“未运行”表述为通过。
