# Ninja — Agent Instructions

This repo provides skills that shape coding-agent behavior. Each skill lives at `skills/<name>/SKILL.md` and is loaded via the harness's skill mechanism. 触发条件以各 `SKILL.md` 的 frontmatter `description` 为准。

## Invocation Discipline

响应用户前先扫一遍触发条件，只要可能适用就**立刻加载 skill** —— 别用"这只是简单问题"或"先收集上下文"自我合理化。

## Skill Authoring Conventions

- **Frontmatter `description` = trigger conditions only.** 把工作流写进 description 会让 agent 跟着 description 走、跳过正文。
- **Cross-skill dependencies use explicit markers** at the relevant section: `**REQUIRED SUB-SKILL:** ninja:<name>`（本 skill 调用的）或 `**REQUIRED BACKGROUND:** ninja:<name>`（agent 必须已知的上下文）。不要用 `@` 语法，它会强制加载并烧 context。
- **Supporting files live next to `SKILL.md`**（`reviewer-prompt.md`、`references/*.md`）。仅在内容超过 ~100 行或被复用时拆文件。
- **Word budget**: 入门 / 高频 skill < 200 词，其他 < 500 词。
