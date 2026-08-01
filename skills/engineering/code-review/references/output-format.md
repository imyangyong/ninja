# Review Output

保持精炼，使用以下结构：

```markdown
## Code Review

**审查方式**：独立 reviewer | 本地 fallback（原因：...）
**模式**：review-only | implementation follow-up
**结论**：不可合并 | 需修改 | 证据不足 | 未发现阻塞问题
**范围**：<scope mode 与实际 diff/path>
**快照**：<base/result OID 或 fingerprint；stable | stale>
**Spec**：<accepted requirement IDs | 未运行及原因 | conflicting IDs>
**验证**：<命令、exit code 与结果摘要；未运行时写原因>

### Evidence

| Ledger | 摘要 | 限制 |
|:-|:-|:-|
| Scope | <entries、status 与 snapshot> | <无或限制> |
| Requirements | <source read status；accepted/rejected/conflicting/superseded requirement IDs> | <无或限制> |
| Environment | <环境组、证据、rubrics、跨组 contract> | <无或限制> |

| 审查轴 | Critical | Important | Minor |
|:-|:-:|:-:|:-:|
| Code Quality | N | N | N |
| Spec Compliance | N / 未运行 | N / 未运行 | N / 未运行 |

### Code Quality

#### [<finding ID>][Critical] 简短标题

- **位置**：path/to/file:line
- **证据与触发**：具体代码行为及现实条件
- **影响**：不修复会发生什么
- **最小修复**：消除风险的可执行改法

### Spec Compliance

#### [<finding ID>][Important][Partial] 简短标题

- **位置**：path/to/file:line
- **需求证据**：<来源> 要求 <相关行为>
- **实现证据**：当前范围与要求的差异
- **影响**：对验收或交付的实际影响
- **最小修复**：满足要求的最小改法

### Implementation Follow-up

- **已修复**：<finding ID → repair>
- **Blocked**：<finding ID → 已请求的新授权或决策>
- **未解决**：<finding ID → post-fix 结果>
- **Minor / not-planned**：<finding ID → 依据>
- **已驳回**：<finding ID → evidence>
```

## Aggregation

- 两个轴分别去重并按 Critical、Important、Minor 排序；同级按影响排序。
- 同一轴多个 reviewer 的同一根因合并为一条，保留最完整证据。
- 轴间 findings 保持原分类；Spec finding 必须有 `requirement_evidence` 与 `coverage_type`。
- initial findings 的 resolution 为 fixed 或 validation 为 rejected 时，只进入 Implementation Follow-up，不计入最终严重度表；需要 post-fix 时，fixed 还必须由 fingerprint-matched 且 prior coverage 完整的结果确认。reconciliation 后为 unresolved/blocked 的 findings 计入。
- review-only 省略 Implementation Follow-up；implementation follow-up 的每种实际 validation/resolution 都要列出，空项写“无”。
- Spec 未运行时保留 Spec Compliance 小节，披露 requirements ledgers，不计为通过或 finding。
- zero-finding 使用各轴 baseline 规定的固定句式。

## Conclusion

按以下顺序选择唯一结论：

1. 任一未解决 Critical：`不可合并`。
2. 无 Critical、任一未解决 Important：`需修改`。
3. 无 Critical/Important，但 snapshot stale、关键审查对象不可读、必需 reviewer 没有合格 result 或完整 fallback、影响关键行为的 requirements conflicting，或用户要求判断可合并而仓库 merge policy/用户明确要求的检查无法取得或因环境原因失败：`证据不足`。
4. 其余情况：`未发现阻塞问题`。

“未发现阻塞问题”只描述已审查范围，不等于未运行的 Spec Compliance 或 checks 已通过。最终报告展示命令、exit code、结果摘要与失败片段；完整输出通过 locator 保留。所有失败、未运行项、fallback 和 evidence limitations 必须披露。
