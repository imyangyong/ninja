# Review Output

保持精炼，使用以下结构：

```markdown
## Code Review

**审查方式**：独立 reviewer | 本地 fallback（原因：...）
**合并裁决**：不可合并 | 修复后可合并 | 可合并
**范围**：<实际审查的代码、文件或 diff 命令>

| Critical | Important | Minor |
|:-:|:-:|:-:|
| N | N | N |

### Code Quality

#### [Critical] 简短标题

- **位置**：path/to/file:line
- **证据**：具体代码行为与现实触发条件
- **影响**：不修复会发生什么
- **最小修复**：消除风险的可执行改法
```

规则：

- finding 按 Critical、Important、Minor 排序；同级按影响排序。
- Critical ≥ 1：`不可合并`。
- 无 Critical 且 Important ≥ 1：`修复后可合并`。
- 只有 Minor 或没有 finding：`可合并`。
- 没有 finding 时明确写“未发现需要行动的 Code Quality 问题”，不要制造表扬或 nitpick 填充报告。
- 代码示例只在能显著澄清最小修复时提供，不强制展示修改前后。
- 不加入 reviewer 未验证的推测，也不隐藏检查失败或 fallback。
