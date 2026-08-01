# Implementation Follow-up

本分支只处理原实现授权范围内的问题；reviewer contract 继续约束所有复审。

## 1. 核验 findings

主 agent 读取真实代码、requirements 与仓库规则，为每条 initial finding 记录 validation：

- `confirmed`：位置、证据、现实触发路径与影响成立；
- `rejected`：代码、测试、需求或仓库规则证明 finding 不成立。

只核验本次实现引入的问题。rejected finding 立即记录 `resolution: not-applicable`；confirmed finding 在下一步完成终态 resolution。

**完成条件**：每条 initial finding 恰好有一个 validation；rejected 均有可验证依据并标为 not-applicable；confirmed 尚未伪装成终态。

## 2. 修复与验证

- 主 agent 修复授权范围内所有 confirmed Critical 与 Important。
- Minor 保持未修改；只有它由本次实现直接造成，且是完成 confirmed 修复所必需的局部收尾时才一并处理。
- verified repair 记录为 `fixed`；需要新授权的 finding 记录为 `blocked`，停止对应修改并请求用户决策；已尝试但验证未通过的 finding 记录为 `unresolved`；未修改的 confirmed Minor 记录为 `not-planned`。
- 修复后运行与 changed behavior 相关的测试、类型检查或 lint，记录命令、snapshot、exit code、结果摘要与完整 output locator，包括既有失败、环境失败与未运行项。

建立 **repair ledger**：finding ID、validation、resolution、依据、修改位置、repair diff、结果 snapshot 与 checks。

**完成条件**：每个 finding 恰好有一个终态 resolution；confirmed Critical/Important 为 fixed、blocked 或 unresolved，confirmed Minor 为 fixed 或 not-planned，rejected 为 not-applicable；blocked 的决策请求已向用户明确提出；repair diff 只包含授权范围；所有检查结果均有 exit code 与摘要，完整输出有 locator 或明确截断记录。

## 3. 最多一次复审

没有 confirmed Critical/Important 或没有 repair diff 时不复审。发生修复时，为每个受影响的 Code Quality environment group，以及受影响的 Spec Compliance 轴，各派发一次 `post-fix` review；提供原始 snapshot、对应 finding states、该 reviewer namespace 的全部 reserved finding IDs、repair diff、结果 snapshot 和检查结果。

先按 reviewer contract 的 Result validation 验证结果。invalid result 只携带 validation errors 重试一次；schema-valid stale result 不重试。再次 invalid 时由主 agent 对同一 reviewer scope 执行本地 fallback 并披露。fallback 因 stale 或 evidence 不可读而无法完成时，将该 scope 的 prior findings 改为 `unresolved`。

只用 `status: complete`、fingerprint matched 且 prior coverage 完整的结果更新 repair ledger：

- 返回且 `prior_finding_id` 匹配的 finding 经主 agent 确认仍成立时，将 prior finding 改为 `unresolved`；若驳回，prior 保持 `fixed`，并记录驳回依据；
- 已列入 `reviewed_prior_finding_ids` 且未返回的 prior finding 保持 `fixed`；
- 新 finding 由主 agent 核验；rejected 记录为 `not-applicable`，confirmed 记录为 `blocked` 或 `unresolved`，不再启动第三轮。

stale 或 fallback 无法完成时记录 evidence limitation，相关 prior finding 保持 `unresolved`。第二轮后终止；所有 unresolved 或新 Critical/Important 保持在最终 findings。

**完成条件**：未发生修复，或每个受影响 reviewer scope 恰好发起一次 `post-fix` review；每个 prior ID 均由合格结果覆盖或保持 unresolved；所有结果均已 reconcile，stale/invalid/fallback 限制均已记录。
