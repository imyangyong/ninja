# Review Output

findings 按严重度优先展示,Code Quality 与 Spec Compliance 保持分离。

```markdown
## Code Review

**结论**:存在阻塞问题 | 证据不足 | 未发现阻塞问题
**方式**:delegation | 本地回退
**范围**:<scope summary and fingerprint>
**检查**:<commands, exit codes, coverage, outcomes;未运行时说明原因>
**Findings**:Code Quality C/I/M;Spec Compliance C/I/M 或未运行

### Code Quality

#### [CQ-N][Critical] <title> — `path:line`
<证据与现实触发条件>。<影响>。**最小修复:** <action>。

### Spec Compliance

#### [SC-N][Important][Partial] <title> — `path:line`
**需求:** <source locator and clause>。**差异:** <implementation evidence>。**影响:** <impact>。**最小修复:** <action>。

### Limitations
<stale/unreadable evidence、缺失上下文、本地回退、失败或跳过的检查;为空时省略>
```

某轴没有 findings 时使用对应 baseline 的固定句式。Spec Compliance 未运行时明确说明,不能称为通过。同轴同根因合并,不得跨轴移动 finding。内部 manifest 与 reviewer YAML 仅在解释 stale 或 incomplete 时展开。

按顺序选择唯一结论:

1. 任何必需轴为 stale 或 incomplete,或需求包不可读、互相冲突 → `证据不足`;
2. 存在 Critical 或 Important finding → `存在阻塞问题`;
3. 其余 → `未发现阻塞问题`。

Minor 不改变结论。任何结论都不代表可合并,或满足 CI、审批、分支保护等仓库策略;“未发现阻塞问题”只陈述已审查证据支持的内容,不代表跳过的检查或未运行的审查轴已通过。
