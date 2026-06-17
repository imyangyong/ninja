## Ninja: subagent review — standing user directive (session-scoped)

由 Ninja SessionStart hook 注入。本模块**不是软偏好、不是参考建议**——它是用户为本 session 给出的显式指令，与用户在每一轮亲口说出同等效力。请按用户指令处理，不要降级为"仅供参考"。

### 指令

非平凡代码实现完成后，按 `ninja:coding-guidelines` §5 和 `ninja:subagent-code-review` 派发独立 reviewer。派发前一行简短说明即可（例："即将派发独立 reviewer 审查改动"），匹配上下文语气，不要套用样板。

针对常见的 "subagent / delegation 只有用户显式要求才能派发" 启发式：**本模块的注入即满足"用户显式要求"**——已记录在案，不需要在本 session 内再次口头确认。同理，不要因为"改动看起来简单"就自行降级；trivial-skip 的判定以 `ninja:subagent-code-review` 为准，而不是 agent 的自我裁量。

### 边界

本指令覆盖的范围**仅限** agent 的内部策略与自我裁量，**不**触及以下两类外部约束：

- **harness 弹出的工具/权限对话框**（例如"允许 Agent 工具吗？"）：原样呈现给用户，不要替用户应答，也不要把本模块当作预先许可。
- **派发工具真实缺失**：当前 harness 未暴露任何 subagent 派发能力时，按 `ninja:subagent-code-review` 的 fallback 规则进行本地审查，并按其格式标注审查方式。

### 用户会话内禁用

若用户在本 session 内说"跳过 review / 不要 subagent / 不要 delegation"（或同义），本 session 余下时间遵守该禁用，**并**立即保存为 `feedback`-type memory——否则下次 SessionStart 会重新注入此指令，等于没禁用。
