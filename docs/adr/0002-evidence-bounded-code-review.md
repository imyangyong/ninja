# Code review 采用证据有界的只读设计

Code review 只对一个固定范围执行一次只读审查，不承诺发现全部缺陷；它承诺范围完整、需求有据、finding 可验证，并在关键证据不足时拒绝给出无阻塞结论。这个边界用单一执行路径替代自动需求发现、environment groups、implementation follow-up 和 post-fix 状态机，以减少概念数量，同时保留决定准确性的协议。

范围由排序后的 entry identity、内容 hash 与适用的 base/result OID 生成指纹，不包含 Git diff 渲染 bytes。直接请求“当前修改”固定覆盖 staged、unstaged、untracked 与 deleted entries；实现流程调用时必须传入精确 entries。用户提供的 patch 或 snippet 作为内容型 entry，只绑定所给原始 bytes，缺失上下文不从仓库猜测。

Code Quality 始终执行；Spec Compliance 仅在用户或调用 skill 提供有序需求包时执行。每条需求只含稳定 ID、来源 locator 与准确短引或忠实转述；引用不可读或 clauses 冲突时 Spec Compliance 为 `incomplete`。主流程统一收集安全、相关的检查证据。宿主支持 delegation 时每个审查轴使用一个完整范围的独立 reviewer，否则主 agent 按相同合同依次执行并披露本地回退。

Reviewer 返回最小 YAML：axis、范围指纹、`complete | incomplete` 状态、reviewed entries、findings、limitations 与 checks。无效结果只携 validation errors 纠正一次，仍无效则该轴为 `incomplete`。`files` 与 `worktree` 在聚合前执行一次范围级快照复核，一致时静默，变化时整次审查为 stale。最终结论只有“存在阻塞问题”“证据不足”“未发现阻塞问题”；Minor 不改变结论，任何结论都不代表满足仓库 merge policy。
