# 最终回复格式

结论先行：

```markdown
**审查结果**：通过 | 修复后通过 | 需人工决策
**审查方式**：subagent | 本地 fallback（原因：<原因>）
**Rubric**：ninja:frontend-code-review | 通用 | 两者（混合改动）
**范围**：<git range 或文件列表>
**轮次**：1 | 2
**验证**：<命令和结果>

已修复：
- [Critical|Important] <文件:行号> <问题> → <修复方式>

未处理（待用户决策）：
- [Severity] <文件:行号> <问题> <为什么没自动修>

Minor 建议（不阻塞）：
- <文件:行号> <建议>

已驳回：
- <文件:行号> <reviewer 观点> → <反驳依据>
```

无任何 finding 时，"已修复 / 未处理 / Minor / 已驳回" 写 "无"。
