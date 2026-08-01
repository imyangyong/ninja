---
name: code-review
description: Code review 用户指定的 patch/snippet、文件、staged/worktree、commit/branch/PR；用于合并前审查，也供 coding-guidelines 在授权实现后触发审查与修复。
---

# Code Review

对固定快照执行双轴隔离审查：

- **Code Quality**：代码自身、公共契约与运行时风险。
- **Spec Compliance**：实现与 accepted requirements 之间的差异。

所有 reviewer 遵守 [reviewer contract and result schema](references/reviewer-contract.md)。

## 0. 确定模式

- **review-only**（默认）：只读评估，并在证据允许时判断是否适合合并。
- **implementation follow-up**：由 `coding-guidelines` 在主 agent 完成用户授权的实现后触发；修复权限等于原实现授权。

**完成条件**：模式唯一；implementation follow-up 已记录原实现授权与精确改动范围。

## 1. 固定范围

读取并执行 [snapshot protocol](references/snapshot-protocol.md)。scope mode 必须来自用户或调用方的明确声明；声明缺失或存在实质歧义时请求具体范围。

implementation follow-up 使用调用方提供的精确 patch、文件集或 commit range；不能与用户既有改动隔离时停止。空范围报告“没有可审查的变更”并结束。

implementation follow-up 仅在以下条件全部成立时跳过 review：diff 增删不超过 3 行；每行仅为不改变行为的普通注释或自然语言错字；文件不作为工具指令、生成输入/产物、配置、schema、公共文档或机器可读内容被消费；不含 rename、mode、symlink、submodule 或 binary change。跳过时逐项报告证据并结束；代码字符串、标识符、directive/doc comment、snapshot 和 fixture 不视为普通错字。

**完成条件**：scope ledger 通过 snapshot protocol 的 schema 与完整性检查；所有可移动 ref 均已解析；初始 fingerprint 与捕获内容一致。

## 2. 收集 Code Quality 证据

按 [reviewer contract](references/reviewer-contract.md) 和 [Code Quality baseline](references/code-quality.md)。建立 quality evidence ledger，包含：

- scope 中每个 entry 的读取状态；
- 当前 snapshot 适用的 `AGENTS.md`、`CLAUDE.md`、`CONTRIBUTING.md`、`CONTEXT.md`、ADR 与项目编码规范；
- 已运行检查的命令、snapshot、覆盖范围、exit code、结果摘要与 artifact key；未运行时记录原因。

另行准备 raw snapshot evidence：captured diff、entry content locator、deleted preimage、检查 output locator，以及 binary/generated/unreadable 限制。ledger 只索引证据，不复制 raw content。

复用用户或调用方提供的有效检查。review-only 只运行已知只读、无需安装依赖且不写入外部系统的现有检查。检查是否足以省略对应问题，按 reviewer contract 的 Deterministic checks 判断。

**完成条件**：每个 scope entry 都有读取状态，以及唯一 raw evidence locator 或明确 limitation；每项规则与检查都绑定 snapshot；每个检查都有可读取的完整结果或明确的未运行/截断记录；限制均已记录。

## 3. 建立 requirements ledgers

读取并执行 [requirements policy](references/requirements-policy.md)。没有 accepted clause 时跳过 Spec Compliance；存在 accepted clauses 时读取 [Spec Compliance baseline](references/spec-compliance.md)。

**完成条件**：每个适用来源通道都已搜索并记录结果；每个候选来源都有 authority、snapshot、读取状态与依据；每个可读来源的相关 clause 都有状态与依据；冲突只影响对应 clause，并已记录对裁决的影响。

## 4. 路由审查环境

按共同 manifest、构建边界、运行环境和调用关系建立 environment groups。独立性证据不足的 entries 放入同组；跨组 changed contract 指定一个负责组或建立 integration group。

通用 Code Quality baseline 始终生效。出现浏览器组件、UI runtime、DOM/渲染 API，或 manifest 与 changed path 共同证明浏览器 UI 环境时，加载 [Frontend rubric](references/rubrics/frontend.md)。HTML、CSS、扩展名、目录名或 bundler 配置不能单独触发。

建立 environment ledger：group ID、paths、运行环境证据、跨组 contract 与 selected rubrics。分组确定后，按每组最小 assigned entry key 的 UTF-8 byte order 排序并分配 `CQG-001` 起的稳定 group ID；integration group 参与同一排序。

**完成条件**：每个 scope entry 恰好有一个 primary group；每条跨组 changed contract 有 reviewer 归属；每组记录实际 rubric 选择。

## 5. 执行独立审查

宿主支持且 delegation 符合当前指令权限时，在声明 scope 内派发只读 reviewer：

- 每个 environment group 按 [Code Quality prompt](references/code-quality-reviewer-prompt.md) 派发一个只读 reviewer，传不含 `user_declaration` 的 snapshot identity projection，并明确该组 assigned entry keys；
- 有 accepted requirements 时，按 [Spec Compliance prompt](references/spec-reviewer-prompt.md) 派发一个只读 reviewer；
- 在宿主并发容量内并行，其余 reviewer 分批执行。

每个 reviewer 只接收本轴原始证据、适用 references 和 snapshot identity，不接收实现者推理、另一轴 findings 或预期答案。

无法 delegation 时，主 agent 先完成并冻结 Code Quality 结果，再用 requirements 与实现原始证据完成 Spec Compliance，并披露：

`审查方式：本地 fallback（原因：<原因>；仅逻辑隔离，无独立上下文）`

聚合前按 reviewer contract 的 Result validation 验证每份结果。invalid initial result 只携带 validation errors 重试一次；再次失败时由主 agent 对该 reviewer scope 执行本地 fallback 并披露。schema-valid stale result 不重试，直接限制裁决。按 snapshot protocol 重算 mutable fingerprint；不一致时将对应结果视为 stale，不作确定性裁决。

**完成条件**：每个 environment group 恰好有一份 schema-valid Code Quality 结果，所有 complete 结果均 fingerprint-matched；Spec 轴有一份同等合格的结果或明确跳过原因；stale 均已限制裁决；snapshot 已复核。

## 6. Implementation follow-up

review-only 跳过本节。implementation follow-up 继续执行 [implementation follow-up](references/implementation-follow-up.md) 的 finding validation、repair 与 post-fix review。

**完成条件**：每条 finding 的 validation 与 resolution 均闭合；所有 confirmed Critical/Important 已 fixed，或以 blocked/unresolved 保留；blocked 所需的用户决策已明确请求；验证与每个受影响 reviewer scope 最多一次复审已完成。

## 7. 输出

按 [output format](references/output-format.md) 分轴去重、排序和裁决。最终报告只展示 ledger 摘要；保留所有证据限制、检查失败、未运行项、fallback、stale snapshot 与 unreadable evidence。

**完成条件**：最终计数与未解决 findings 一致；裁决符合输出规则；finding 保持原审查轴；所有限制均已披露。
