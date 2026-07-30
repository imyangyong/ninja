# Review Output

保持精炼，使用以下结构：

```markdown
## Code Review

**审查方式**：独立 reviewer | 本地 fallback（原因：...）
**模式**：review-only | implementation follow-up
**结论**：不可合并 | 需修改 | 证据不足 | 未发现阻塞问题
**范围**：<scope mode 与实际 diff/path>
**快照**：<base/result OID 或 fingerprint；stable | stale>
**Spec**：<accepted sources | 未运行及原因 | conflicting>
**验证**：<命令与完整结果；未运行时写原因>

### Evidence

| Ledger | 摘要 | 限制 |
|:-|:-|:-|
| Scope | <changed/deleted/untracked paths 与 snapshot> | <无或限制> |
| Requirements | <accepted/rejected/unreadable/conflicting sources> | <无或限制> |
| Environment | <环境组、证据、rubrics、跨组 contract> | <无或限制> |

| 审查轴 | Critical | Important | Minor |
|:-|:-:|:-:|:-:|
| Code Quality | N | N | N |
| Spec Compliance | N / 未运行 | N / 未运行 | N / 未运行 |

### Code Quality

#### [Critical] 简短标题

- **位置**：path/to/file:line
- **证据与触发**：具体代码行为及现实条件
- **影响**：不修复会发生什么
- **最小修复**：消除风险的可执行改法

### Spec Compliance

#### [Important][Partial] 简短标题

- **位置**：path/to/file:line
- **需求证据**：<来源> 要求 <相关行为>
- **实现证据**：当前范围与要求的差异
- **影响**：对验收或交付的实际影响
- **最小修复**：满足要求的最小改法

### Implementation Follow-up

- **已修复**：<finding → repair>
- **未解决**：<finding → blocked 原因或 POST_FIX 结果>
- **Minor**：<未修改，或局部收尾依据>
- **已驳回**：<finding → evidence>
```

## Aggregation

- 两个轴分别去重并按 Critical、Important、Minor 排序；同级按影响排序。
- 同一轴多个 reviewer 的同一根因合并为一条，保留最完整证据。
- 轴间 findings 保持原分类；Spec finding 必须有 requirement evidence 与 coverage type。
- initial findings 被修复或 rejected 后只进入 Implementation Follow-up，不计入最终严重度表。
- review-only 省略 Implementation Follow-up；implementation follow-up 的每种 disposition 都要列出，空项写“无”。
- Spec 未运行时保留 Spec Compliance 小节，披露 requirements ledger，不计为通过或 finding。
- zero-finding 使用各轴 baseline 规定的固定句式。

## Conclusion

按以下顺序选择唯一结论：

1. 任一未解决 Critical：`不可合并`。
2. 无 Critical、任一未解决 Important：`需修改`。
3. 无 Critical/Important，但 snapshot stale、关键审查对象不可读、同级 requirements conflicting，或用户要求判断可合并而仓库 merge policy 或用户明确要求的检查无法取得：`证据不足`。
4. 其余情况：`未发现阻塞问题`。

“未发现阻塞问题”只描述已审查范围，不等于未运行的 Spec Compliance 或 checks 已通过。所有失败、未运行项、fallback 和 evidence limitations 必须保留。
