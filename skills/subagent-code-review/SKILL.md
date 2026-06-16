---
name: subagent-code-review
description: 完成非平凡代码实现（新功能 / bug 修复 / 跨模块改动 / 重构）后触发；用户说 "review 我刚改的 / 用 subagent review / delegated review" 时触发；被 ninja:coding-guidelines §5 调用时触发。
---

# Subagent Code Review

完成代码实现后，**默认**用独立上下文的 subagent 审查刚写的代码，再根据反馈自动修复。独立上下文可以避免实现者被自己的假设、计划和乐观报告影响。

**工作产物**：派发 1-2 个独立 reviewer subagent → 自动修复 Critical/Important → 输出结构化报告。

## Skill 依赖

- **REQUIRED SUB-SKILL (conditional):** `ninja:frontend-code-review` — 当改动包含前端文件时，由派发的 reviewer subagent 通过 Skill tool 加载并作为 rubric。
- **REQUIRED BACKGROUND:** `ninja:coding-guidelines` — 本 skill 由 coding-guidelines §5 默认触发；用户没有显式禁用前不要跳过。

## 何时运行

**默认运行**：完成任何非平凡（non-trivial）代码实现后——新功能、bug 修复、跨模块改动、重构。

**显式运行**：用户要求 "用 subagent review / 独立 agent 审查 / delegated review"，或被 `ninja:coding-guidelines` §5 触发。

**不要运行**：
- 改动 ≤ 3 行且明显无副作用（错别字、注释、变量重命名）。
- 用户明确说 "跳过 review / 不用 subagent / 不要 delegation"。

## 何时 fallback 到本地审查

仅以下两种情况退回本地审查，并在最终回复明确标注 `审查方式：本地 fallback（原因：<原因>）`：

1. 当前 harness 没有派发 subagent 的能力（无 Agent / Task / spawn-agent / activate_agent 等工具）。
2. 用户明确禁用 delegation。

**其他情况一律派发 subagent**——不要因为"改动看起来简单"或"自己能 review"就跳过。

## 流程

### 1. 确定审查范围

按优先级取一项：
- 用户指定的文件、目录或 diff。
- 暂存区：`git diff --cached`（若非空）。
- 工作区：`git diff HEAD`。
- 已提交范围：记录 `BASE_SHA` 与 `HEAD_SHA`，用 `git diff BASE_SHA..HEAD_SHA`。

### 2. 路由 rubric

对每个改动文件做前端 / 非前端 / 配置分类，按结果路由到 1 个或 2 个 reviewer。细则见 [references/routing.md](references/routing.md)。

### 3. 派发 subagent

使用当前 harness 提供的 subagent 派发能力（Claude Code 的 `Agent` 工具、Codex 的 sub-agent、Gemini CLI 的 `activate_agent` 等），选择"能读全部仓库文件 + 能跑 git + 能加载 skill"的通用 subagent 类型。

Reviewer prompt 用 [references/subagent-reviewer-prompt.md](references/subagent-reviewer-prompt.md) 模板，填入这些字段：

| 占位符 | 内容 |
|---|---|
| `RUBRIC_SKILL` | 前端 reviewer 填 `ninja:frontend-code-review`；通用 reviewer 填 `（无）` |
| `DESCRIPTION` | 本次实现的简短说明（1-3 句），不含推理过程 |
| `REQUIREMENTS` | 需求 / 计划 / 用户原话；无独立 plan 时写 "无独立 plan，按代码本身校准" |
| `SCOPE` | git range 或文件列表（混合改动时只列该 reviewer 负责的文件） |
| `TEST_RESULTS` | 已运行的测试 / 类型检查 / lint 命令及完整结果（包括失败） |
| `ROUND` | `1`（首轮）；自动修复后第二轮派发时填 `2` |
| `PRIOR_FINDINGS` | 第 1 轮填 `（无）`；第 2 轮粘贴上一轮所有 Critical/Important 条目 |

**不要**把你的推理、怀疑点或预期答案塞进 prompt，否则会污染 reviewer 的独立判断。

### 4. 处理反馈

按 severity 处理 + 反驳明显误判 + 最多 2 轮循环——细则与终止条件见 [references/feedback-handling.md](references/feedback-handling.md)。

### 5. 完成前验证

- 重新跑与改动相关的测试 / 类型检查 / lint。
- 按 [references/output-format.md](references/output-format.md) 输出结构化结果。

## 两段式审查（可选）

**仅当同时满足以下两点**才拆成两段，否则一律 combined：
1. 用户提供了独立的需求文档或实现计划。
2. 改动较大（> 200 行 或 > 5 个文件）。

两段顺序：
1. **Spec compliance**：只判 "是否实现了要求、有无多做或少做"。spec 不合格先修，不进入下一段。
2. **Code quality**：spec 合格后再按 rubric 检查代码质量。

默认 **combined**：一次 subagent 同时审 spec 与质量（模板已涵盖两者）。
