---
name: code-review
description: 审查用户指定的代码、文件、目录、暂存区、工作区、分支或 PR 改动并给出只读的 Code Quality 与可用时的 Spec Compliance 报告。当用户要求只读 code review、代码审查/评审/走查、PR review、review since 某个 ref，或询问代码与改动是否可合并时使用；不用于已授权实现后的自动修复复审。
---

# Code Review

执行只读 Code Quality 审查；存在可读需求时另行执行 Spec Compliance。用户要求 review 不代表授权修改代码。

## 1. 固定范围

按顺序选择第一项：

1. 用户指定的代码、文件、目录、git 范围，或明确的 branch/PR 审查意图。
2. 非空暂存区：`git diff --cached`。
3. 非空工作区：`git diff HEAD`。

branch/PR 未给 fixed point 时立即询问，不转而审查暂存区或工作区，也不猜测 `main`/`master`。验证 fixed point 后使用 `git diff <fixed-point>...HEAD`。

在派发前验证范围：代码片段非空；文件/目录存在且含可审查文件；git ref 可解析且 diff 非空。任何显式范围无效、为空或仍有歧义时停止并说明，不派发 reviewer。

运行并记录唯一的 diff 命令、变更文件与完整文件快照来源。按文件状态读取：

- 新增/修改文件从范围的结果端读取：暂存区用 `git show :<path>`；工作区或直接指定的文件用 filesystem；`<fixed-point>...HEAD` 用 `git show HEAD:<path>`。
- 删除文件从范围的 preimage 读取：暂存区/工作区用 `git show HEAD:<path>`；三点范围先记录 `git merge-base <fixed-point> HEAD` 的输出，再从该 merge-base 读取。
- 其他显式 git 范围同样分别记录结果端与 base 端；不得用未暂存 filesystem 内容替代 index 或 commit 快照。

代码片段与完整文件审查不要求构造 git diff。

## 2. 收集证据

读取 diff、每个受影响文件的完整内容及理解行为所需的直接依赖。查找 `AGENTS.md`、`CLAUDE.md`、`CONTRIBUTING.md`、`CONTEXT.md` 和项目编码规范；仓库规则优先。

读取 [references/code-quality.md](references/code-quality.md) 作为始终生效的通用基线。跳过 formatter、linter、type checker 能可靠判定的问题，但可引用其实际失败解释更深层风险。

## 3. 发现需求

按以下优先级收集与当前范围直接相关的 requirements sources：

1. 用户直接提供的需求文字，或明确指定的 spec、文件、URL、issue、commit。
2. 当前 PR 的 title/body/linked issues，或 review 范围的 commit message/body 明确引用的 issue、commit 或需求来源。
3. 变更模块直接引用或同目录明确匹配的 PRD、spec、requirements、验收文档。

读取候选内容后才可纳入需求集；记录来源、优先级与可读性。不可读或只提供项目背景而没有可验证行为的候选不作为 spec，并在报告披露。来源冲突时以上述优先级为准，同级冲突则停止 Spec Compliance 并请求澄清，但 Code Quality 继续。

若没有可读 spec，跳过 Spec Compliance 并明确说明，不阻塞 Code Quality。若存在，读取 [references/spec-compliance.md](references/spec-compliance.md)；不得把需求缺口移入 Code Quality findings。

## 4. 检测代码环境

读取 [references/rubrics/registry.md](references/rubrics/registry.md)。仅使用所选范围对应的文件快照、manifest、依赖、配置与模块边界作为证据，由 AI 最终决定 specialized rubric：

- 有充分证据时加载匹配 rubric；frontend 不享有默认优先级。
- 证据不足时只用通用基线，并记录未选择 specialized rubric 的原因。
- 高度相关的文件归入一个环境组并加载所有适用 rubrics，不按扩展名机械拆分。
- 仅当模块边界与运行环境明显独立时拆组；每组只派发一个 reviewer，并限制其文件范围。

在派发前记录每组的文件、环境证据与 rubric 路径。

## 5. 独立审查

有 subagent 能力且用户未禁用 delegation 时：

- 使用 [references/reviewer-prompt.md](references/reviewer-prompt.md) 为每个环境组派发只读 Code Quality reviewer。
- 存在 spec 时，使用 [references/spec-reviewer-prompt.md](references/spec-reviewer-prompt.md) 另派一个只读 Spec Compliance reviewer。
- 同时派发可并行的 reviewers。两个轴使用隔离上下文：质量 reviewer 不接收 spec 或合规猜测；合规 reviewer 不接收质量基线、specialized rubrics 或质量 findings。只提供各自 prompt 列出的原始证据。

否则由主 agent 分开执行相同审查，并标注：

`审查方式：本地 fallback（原因：<无 subagent 能力 | 用户禁用 delegation>；未实现独立上下文）`

reviewer 必须核对完整文件，只报告有具体证据、可在当前范围触发且值得行动的问题。任何 reviewer 都不得修改文件。

## 6. 输出

按 [references/output-format.md](references/output-format.md) 分轴聚合；只在同一轴内去重和按严重度排序，不跨轴移动或重排 findings。披露 spec 发现结果及各环境组 specialized rubrics。根据两个轴中已确认的最高严重度生成一个合并裁决。验证 reviewers 没有修改文件；本 skill 在任何情况下都不修复 findings。
