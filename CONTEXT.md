# Ninja

Ninja 定义可预测的 engineering skills，以及这些 skills 对执行结果作出的行为承诺。

## Language

**证据有界准确性**：
Code review 不承诺发现全部缺陷；它承诺审查范围完整、需求来源有据、finding 可验证，并在关键证据不足时拒绝给出无阻塞结论。
_Avoid_: 完全准确、零漏报

**范围指纹**：
证明一次审查所覆盖对象及其内容身份未发生变化的摘要；不证明 diff 的展示文本或生成方式相同。
_Avoid_: Diff 指纹、审查结果指纹

**需求包**：
由用户或调用 skill 明确交给 code review 的有序验收 clauses；每条只含稳定 ID、来源 locator 与准确短引或忠实转述。
_Avoid_: 推测需求、自动发现需求

**轴审查者**：
只接收完整审查范围和单一审查轴证据的 reviewer；一次 review 至多有一个 Code Quality 轴审查者和一个 Spec Compliance 轴审查者。
_Avoid_: Environment reviewer、分组 reviewer

**审查状态**：
轴审查者对证据完整性的判定：`complete` 表示范围已完整审查，`incomplete` 表示关键对象或证据不可用。可变范围身份变化时，整次审查而非单轴为 `stale`。
_Avoid_: 用 limitation 代替状态、部分通过

**当前修改**：
直接调用 code review 时代表 Git worktree 中全部 staged、unstaged、untracked 与 deleted entries；自动实现流程不得使用该默认范围。
_Avoid_: 仅 `git diff`、仅 unstaged changes

**Code review**：
对固定范围作一次只读、证据有界判断的流程；它不理解修复阶段、不修改实现，也不拥有 finding resolution。
_Avoid_: Review-and-fix、自动修复

**检查证据**：
由主审查流程统一收集并交给所有轴审查者的命令、退出状态、覆盖范围与结果；它是审查输入，不由 reviewer 各自生成。
_Avoid_: Reviewer checks、推测性通过

**审查结论**：
对必需审查轴的证据状态与阻塞级 findings 作出的汇总，只能是存在阻塞问题、证据不足或未发现阻塞问题；它不表示满足仓库 merge policy。
_Avoid_: 可以合并、审查通过

**变更归因**：
Finding 与审查范围的关系：变更型范围只报告本次变化引入或暴露的问题，内容型范围则审查全部给定内容；周边代码只提供证据。
_Avoid_: 顺手审查、范围外 finding

**精简设计**：
以单一执行路径、单一真相和最少领域概念为目标的 skill 设计；不以删除完成条件或机械压缩行数为目标。
_Avoid_: 最短文本、摘要式协议

**专项 rubric**：
仅在审查证据明确证明对应 runtime 存在时加载的 Code Quality 增量规则；文件扩展名或目录名称不能单独触发。
_Avoid_: 默认 rubric、按路径猜测 runtime

**Finding**：
由审查范围引入或暴露、具有现实触发条件、具体后果和最小修复的问题；Minor 也必须满足该门槛。
_Avoid_: 建议、风格偏好、推测风险

**本地回退**：
宿主无法提供独立轴审查者时，由主 agent 依次执行相同审查合同的方式；它必须披露，但本身不构成证据不足。
_Avoid_: 降级审查、无效审查
