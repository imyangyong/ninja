# Spec Compliance Baseline

只比较需求包 clauses 与固定审查范围。该轴不评价一般代码质量。

## Evidence

- 读取完整需求及必要实现路径,每条 finding 指向需求包中的具体 clause。
- 需求沉默不产生新要求,不从沉默推导范围蔓延。
- 范围外既有缺口可作为 limitation 披露,不计入 finding 或结论。

## Coverage

- **Missing**:要求的行为、路径或产物完全未实现。
- **Partial**:主路径存在,但要求的边界、错误路径、平台或验收条件缺失。
- **Incorrect**:实现行为与要求相反、结果错误或契约不兼容。
- **Unrequested**:需求明确禁止某行为或声明穷举范围,而实现增加了该行为。

每条 finding 在 reviewer contract 的公共字段之外,还必须包含:

- `requirement_id` 与 `requirement_evidence`:clause ID、来源 locator 及短引或准确转述;
- `coverage_type`:Missing、Partial、Incorrect 或 Unrequested;
- `implementation_evidence`:当前范围与要求之间的可观察差异。

没有 finding 时返回:“当前范围符合需求包要求。”
