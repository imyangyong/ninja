# Spec Compliance Baseline

只比较已验证可读的 requirements sources 与当前 review 范围。该轴不评价一般代码质量；代码是否优雅、安全或易维护属于 Code Quality。

## Evidence rules

- 先读取完整需求来源，再检查 diff、完整变更文件及必要调用路径。
- 每条 finding 必须指出需求来源与相关要求，可短引或准确转述，并给出实现位置和现实差异。
- 来源冲突时遵循主 skill 的优先级；不得自行发明产品意图或用低优先级来源覆盖高优先级要求。
- 只报告可由当前范围修复的差异。范围外的既有缺口可以说明，但不计入 finding 或裁决。
- 建议满足需求的最小修复，不借合规审查扩大产品范围。

## Coverage

- **Missing**：要求的行为、路径或产物完全未实现。
- **Partial**：主路径存在，但要求的边界、错误路径、平台或验收条件缺失。
- **Incorrect**：实现行为与要求相反、结果错误或契约不兼容。
- **Unrequested**：在权威需求明确禁止某行为或声明穷举范围时，新增未授权的外部行为或范围。需求沉默本身不证明范围蔓延。
- **Plan defect**：待审计划遗漏必要步骤、顺序不可行或与明确要求冲突。仅当 review 范围包含计划时适用。

## Severity

- **Critical**：核心需求无法工作、结果严重错误、数据/安全风险直接违反要求，或未要求行为造成不可接受的破坏。
- **Important**：需求有实质漏做、部分实现或错误实现，合并前应修复。
- **Minor**：不阻塞核心验收的局部合规偏差。不要把需求措辞歧义当成 finding。

## Finding contract

每条 finding 包含 severity、实现或计划位置、requirement evidence（来源 + 相关要求）、实现证据、影响与最小修复。没有 finding 时明确说明当前范围符合已提供 spec。
