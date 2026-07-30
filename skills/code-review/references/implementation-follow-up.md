# Implementation Follow-up

仅在主 agent 已获代码实现授权并完成实现后使用。普通 review-only 请求不得进入本流程。所有 reviewer 始终只读；只有主 agent 可修改当前授权范围内的代码。

## 1. 核验 findings

主 agent 对每条 finding 读取真实代码、需求和仓库规范后记录 disposition：

- **confirmed**：位置与证据存在，触发路径现实，且修复不违反更高优先级需求或仓库规则。
- **rejected**：用代码、测试、需求或仓库规则说明误判依据。仅凭实现者偏好不能驳回。
- **blocked**：finding 属实，但最小修复需要新的产品/架构选择、破坏性操作、删除既有功能，或改变未经授权的外部 API、数据 schema 或范围。

只处理当前实现或其修复引入的问题；不要借 review 清理既有债务。

## 2. 修复与验证

- 主 agent 修复所有 confirmed Critical 与 Important。
- Minor 默认不修。只有它是本次实现直接造成、且完成已确认修复所必需的局部收尾时才可一并处理。
- blocked finding 不得擅自修复；停止需要该决策的修改并请求用户。
- 修复后运行与受影响行为相关的测试、类型检查或 lint。记录完整命令和结果，包括既有失败、环境失败与未运行项；不得把失败省略或报告为通过。

## 3. 最多一次复审

首轮没有 confirmed Critical/Important，或没有修改文件时，不派发复审。发生修复时最多再派发一轮受影响轴的 reviewer，并提供：

- 原始审查范围与快照；
- 首轮 confirmed/rejected/blocked findings；
- 主 agent 的修复 diff 与结果快照；
- 修复后检查的完整结果。

第二轮只验证 confirmed findings 是否解决，并审查修复 diff 是否引入新的 Critical/Important；不要重审未触碰的原范围或新增 Minor 配额。reviewer 仍不得修改文件。

第二轮后终止。若仍有 confirmed Critical/Important，合并裁决保持阻塞并如实报告，不派发第三轮。若新 finding 的修复需要新授权，同样停止并请求用户。

local fallback 使用相同核验、修复、验证与轮次上限，但必须保持两个审查轴的本地上下文分离，并披露没有独立 reviewer。
