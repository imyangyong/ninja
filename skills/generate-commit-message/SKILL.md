---
name: generate-commit-message
description: 生成符合 Conventional Commits 规范的提交消息。当用户要求写 commit message / 提交信息、帮忙提交代码（"帮我提交一下"），或给出 git diff / 代码改动让你总结成提交消息时使用。
---

# 生成 Commit Message

分析代码变更，生成一条符合 [Conventional Commits](https://www.conventionalcommits.org/) 规范的提交消息。

## 第一步：确定变更范围

在生成提交消息前，先明确要为哪些改动生成。按以下优先级判断：

1. **用户直接提供**——用户粘贴了 `git diff` 输出、修改前后的代码对比，或用自然语言描述了改动，则直接基于此内容生成。
2. **暂存区改动**——运行 `git diff --staged` 获取已暂存的改动（这是 `git commit` 实际会提交的内容，优先使用）。
3. **工作区改动**——若暂存区为空，运行 `git diff HEAD` 获取全部未提交改动。

> 若以上都无法确定范围，**先向用户询问**要为哪些改动生成提交消息，不要凭空假设。

生成前可运行 `git log --oneline -10` 查看历史提交，以对齐其语言与风格（见下方规则）。

## 第二步：输出格式

**格式:**
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**type**：`feat` | `fix` | `docs` | `style`（代码格式，非 CSS）| `refactor` | `perf` | `test` | `chore` | `ci` | `revert`

**规则:**
- subject 用祈使语气，首字母小写，无句号，不超过 72 字符
- 破坏性改动在 footer 写 `BREAKING CHANGE: <描述>`
- body/footer 仅在必要时添加
- 语言跟随仓库历史提交；若无上下文，默认使用英文

## 示例

**输入 diff：**
```diff
- const timeout = 3000
+ const REQUEST_TIMEOUT_MS = 3000
```

**输出：**
```
refactor(config): replace magic number with named constant

Replace hardcoded timeout value with REQUEST_TIMEOUT_MS for clarity
and maintainability.
```
