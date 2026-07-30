# Review Output

保持精炼，使用以下结构：

```markdown
## Code Review

**审查方式**：独立 reviewer | 本地 fallback（原因：...）
**模式**：review-only | implementation follow-up
**合并裁决**：不可合并 | 修复后可合并 | 可合并
**范围**：<实际审查的代码、文件或 diff 命令>
**Spec 来源**：<已验证来源，或“未发现可读 spec；Spec Compliance 未运行”>
**轮次**：1 | 2
**验证**：<命令与完整结果；review-only 未执行则写“未执行额外检查”>

### 环境与 Rubrics

| 环境组 | 证据 | Specialized rubrics |
|:-|:-|:-|
| <文件或模块> | <manifest / dependency / config / code evidence> | <rubric names，或“无（原因）”> |

| 审查轴 | Critical | Important | Minor |
|:-|:-:|:-:|:-:|
| Code Quality | N | N | N |
| Spec Compliance | N / 未运行 | N / 未运行 | N / 未运行 |

### Code Quality

#### [Critical] 简短标题

- **位置**：path/to/file:line
- **证据**：具体代码行为与现实触发条件
- **影响**：不修复会发生什么
- **最小修复**：消除风险的可执行改法

### Spec Compliance

#### [Important] 简短标题

- **位置**：path/to/file:line
- **需求证据**：<来源> 要求 <相关行为>
- **实现证据**：当前范围如何漏做、部分实现、错误实现或增加未要求行为
- **影响**：对验收或交付范围的实际影响
- **最小修复**：满足该要求的最小改法

### Implementation Follow-up

- **已修复**：[Critical|Important] <finding> → <主 agent 的最小修复>
- **未解决**：[Critical|Important] <finding> → <blocked 原因或第二轮结果>
- **Minor**：<未修改的建议，或直接收尾时的处理依据>
- **已驳回**：<finding> → <代码、测试、需求或仓库规则证据>
```

规则：

- 两个轴分别呈现；finding 只在各自轴内按 Critical、Important、Minor 排序，同级按影响排序。不得跨轴移动或重新排名。
- review-only 省略 Implementation Follow-up 小节且禁止写入。implementation follow-up 必须列出各 finding disposition；空项写“无”。
- implementation follow-up 的严重度表、轴内 findings 与合并裁决只反映最终轮次仍未解决的问题；已修复与已驳回项只记在 disposition 中，不重复计数。
- 通用 Code Quality 基线始终生效；环境表必须披露每组 specialized rubric 的选择结果。
- 多 reviewer 在同一轴报告同一根因时合并为一条，保留最完整证据，不累计计数。
- 两个轴任一未解决 Critical ≥ 1：`不可合并`。
- 两个轴均无未解决 Critical、任一未解决 Important ≥ 1：`修复后可合并`。
- 只有 Minor 或没有 finding：`可合并`。
- 没有 finding 时明确写“未发现需要行动的 Code Quality 问题”，不要制造表扬或 nitpick 填充报告。
- 有 spec 但没有合规 finding 时写“当前范围符合已提供 spec”。没有可读 spec 时保留 Spec Compliance 小节并写明未运行及发现过程，不把它计为通过或 finding。
- 每条 Spec Compliance finding 必须包含 requirement evidence；缺少需求来源或对应要求的候选 finding 应丢弃。
- 代码示例只在能显著澄清最小修复时提供，不强制展示修改前后。
- 不加入 reviewer 未验证的推测，也不隐藏检查失败或 fallback。
