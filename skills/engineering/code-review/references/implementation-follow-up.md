# Implementation Follow-up

本分支只处理原实现授权范围内的问题；reviewer contract 继续约束所有复审。

## 1. 核验 findings

主 agent 读取真实代码、需求和仓库规则，为每条 finding 记录一种 disposition：

- **confirmed**：位置、证据和现实触发路径均成立，最小修复符合更高权威需求与仓库规则。
- **rejected**：代码、测试、需求或仓库规则证明 finding 不成立。
- **blocked**：finding 属实，但修复需要新的产品或架构选择、破坏性操作、删除既有功能，或改变未经授权的外部 API、data schema 或范围。

只核验本次实现或其 repair diff 引入的问题。

**完成条件**：每条 finding 恰好有一个 disposition，且 rejected/blocked 都有可验证依据。

## 2. 修复与验证

- 主 agent 修复授权范围内所有 confirmed Critical 与 Important。
- Minor 保持未修改；只有它由本次实现直接造成，且是完成 confirmed 修复所必需的局部收尾时才一并处理。
- blocked finding 停止对应修改并请求用户决策。
- 修复后运行与 changed behavior 相关的测试、类型检查或 lint，记录命令、snapshot 和完整结果，包括既有失败、环境失败与未运行项。

建立 **repair ledger**：finding、disposition、修改位置、repair diff、结果 snapshot 与 checks。

**完成条件**：每个 confirmed Critical/Important 都有 repair ledger 条目或 blocked 决策；repair diff 只包含授权范围；所有检查结果完整记录。

## 3. 最多一次复审

没有 confirmed Critical/Important 或没有 repair diff 时不复审。发生修复时，仅为受影响轴派发一次 POST_FIX review，提供 reviewer contract 要求的原始范围、dispositions、repair diff、结果 snapshot 和检查结果。

第二轮结束后终止。仍未解决或新发现的 Critical/Important 保持在最终 findings；需要新授权的修复转为 blocked。

**完成条件**：未发生修复，或每个受影响轴恰好完成一次 POST_FIX review；第二轮结果已写回 repair ledger。
