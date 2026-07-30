---
name: code-review
description: 审查用户指定的代码、文件、目录、暂存区、工作区、分支或 PR 改动并给出只读的 Code Quality 报告。当用户要求只读 code review、代码审查/评审/走查、PR review、review since 某个 ref，或询问代码与改动是否可合并时使用；不用于已授权实现后的自动修复复审。
---

# Code Review

执行只读 Code Quality 审查。用户要求 review 不代表授权修改代码。

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

## 3. 检测代码环境

读取 [references/rubrics/registry.md](references/rubrics/registry.md)。仅使用所选范围对应的文件快照、manifest、依赖、配置与模块边界作为证据，由 AI 最终决定 specialized rubric：

- 有充分证据时加载匹配 rubric；frontend 不享有默认优先级。
- 证据不足时只用通用基线，并记录未选择 specialized rubric 的原因。
- 高度相关的文件归入一个环境组并加载所有适用 rubrics，不按扩展名机械拆分。
- 仅当模块边界与运行环境明显独立时拆组；每组只派发一个 reviewer，并限制其文件范围。

在派发前记录每组的文件、环境证据与 rubric 路径。

## 4. 独立审查

有 subagent 能力且用户未禁用 delegation 时，使用 [references/reviewer-prompt.md](references/reviewer-prompt.md) 为每个环境组派发只读 reviewer；多组可并行。只提供原始范围、组内文件、快照来源、环境证据、rubric 路径、标准来源和检查结果，不泄露主 agent 的猜测。

否则由主 agent 使用相同基线审查，并标注：

`审查方式：本地 fallback（原因：<无 subagent 能力 | 用户禁用 delegation>）`

reviewer 必须核对完整文件，只报告有具体证据、可在当前范围触发且值得行动的问题。

## 5. 输出

按 [references/output-format.md](references/output-format.md) 聚合并去重，披露各环境组选择或未选择的 specialized rubrics。验证 reviewer 没有修改文件；本 skill 在任何情况下都不修复 findings。
