---
name: code-review
description: 只读审查用户指定的 patch/snippet、文件、当前修改(staged/unstaged/untracked/deleted)、commit/range/branch 或 PR;也用于 coding-guidelines 要求的实现后审查。
---

# Code Review

对一个固定范围做一次只读审查:不修改代码、不参与修复。修复后如需复审,由调用方重新发起一次审查。

审查轴:

- **Code Quality**:每个非空范围都执行,没有微小改动跳过规则。正确性、安全性、架构、测试、性能与可维护性。
- **Spec Compliance**:仅在用户或调用方显式提供需求包时执行。

## 1. 固定范围

执行 [snapshot protocol](references/snapshot-protocol.md)。范围模式来自用户或调用方的明确声明;缺失或有实质歧义时询问,无法形成唯一范围时停止,不猜测。直接审查“当前修改”时覆盖全部 staged、unstaged、untracked 与 deleted entries;实现流程调用必须传入本次改动的精确范围,不能与既有改动隔离时停止。空范围直接结束。

**完成条件**:每个变更项恰好有一个可验证 entry 或明确 limitation;所有 ref 已解析;fingerprint 可独立重算。

## 2. 收集证据

读取 diff、受影响实现路径与适用的仓库指令。

- **共享检查**:由主流程统一执行只读、安全的检查一次,记录 command、exit code、coverage、outcome 与失败或跳过原因,作为所有轴的共享检查证据;轴审查者不重复执行。
- **需求包**:只接受显式提供的有序 clauses,每条含稳定 ID、来源 locator 与准确短引或忠实转述;缺 ID 按输入顺序补齐。不从 PR、commit、邻近文档、ADR 或 issue tracker 自动发现需求。引用不可读或 clauses 冲突时 Spec Compliance 为 incomplete;没有需求包时不运行,且不能称为通过。

**完成条件**:每个范围项可读或有明确 limitation;每个相关检查已执行或记录跳过原因;需求包已验证,或记录不可读/冲突。

## 3. 执行审查轴

加载 [Code Quality baseline](references/code-quality.md);仅当 runtime 证据证明浏览器 UI 时另加载 [Frontend rubric](references/rubrics/frontend.md),文件扩展名或目录名不能单独触发。

宿主支持 delegation 时,每个轴派发一个完整范围的独立轴审查者,容量允许时两轴并行。派发输入:预期 fingerprint、完整 entry 集合、可读取的原始证据、共享检查证据,Spec 轴另附需求包。reviewer 只接收原始证据,不接收实现者推理或另一轴 findings。无法 delegation 时,主 agent 按相同合同先完成并冻结 Code Quality,再执行 Spec Compliance,并披露本地回退。

按 [reviewer contract](references/reviewer-contract.md) 验证结果;invalid 结果只携 validation errors 重试一次,再次 invalid 则该轴为 incomplete。聚合前按 snapshot protocol 对可变范围执行一次快照复核。

**完成条件**:Code Quality 覆盖全部范围;Spec Compliance 已执行或明确未运行;每个结果通过 contract 验证或记为 incomplete;可变范围已通过快照复核或整次审查记为 stale。

## 4. 汇总报告

使用 [output format](references/output-format.md)。两轴分离,仅同轴同根因去重。结论按证据优先级得出,只陈述已审查证据支持的内容,不代表满足仓库 merge policy。

**完成条件**:披露 stale/unreadable evidence、缺失上下文、失败或跳过的检查与本地回退;每条 finding 符合 contract;结论符合优先级规则。
