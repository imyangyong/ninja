# Spec Compliance Baseline

只比较 requirements ledger 中 accepted sources 与 scope ledger。该轴不评价一般代码质量。

## Evidence

- 读取完整需求及必要实现路径，每条 finding 指向权威来源中的具体要求。
- 按 requirements ledger 的权威顺序解释来源；需求沉默不产生新要求。
- 范围外既有缺口可作为限制披露，不计入 finding 或裁决。

## Coverage

- **Missing**：要求的行为、路径或产物完全未实现。
- **Partial**：主路径存在，但要求的边界、错误路径、平台或验收条件缺失。
- **Incorrect**：实现行为与要求相反、结果错误或契约不兼容。
- **Unrequested**：权威需求明确禁止某行为或声明穷举范围，而实现增加了该行为。需求沉默本身不证明范围蔓延。

每条 finding 在 reviewer contract 的公共字段之外，还必须包含：

- `requirement evidence`：来源标识及短引或准确转述；
- `coverage type`：Missing、Partial、Incorrect 或 Unrequested；
- `implementation evidence`：当前范围与要求之间的可观察差异。

没有 finding 时返回：“当前范围符合 accepted requirements sources。”
