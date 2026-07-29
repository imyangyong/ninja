# Ninja — 贡献指南

本仓库提供用于规范 coding agent 行为的 skills。每个 skill 位于 `skills/<name>/SKILL.md`，由 harness 的 skill 机制加载；其触发条件以对应 `SKILL.md` 的 frontmatter `description` 为准。

## Skill 编写约定

- **Frontmatter `description` 只写触发条件。** 不要把工作流写入 `description`，否则 agent 可能直接按其执行并跳过正文。
- **跨 skill 依赖使用显式标记。** 在相关章节使用 `**REQUIRED SUB-SKILL:** <name>`（当前 skill 需要调用）或 `**REQUIRED BACKGROUND:** <name>`（agent 必须已具备相关上下文），`<name>` 为目标 skill 的裸名（frontmatter `name` 字段）。不要使用 `@` 语法，因为它会强制加载并额外占用 context。
- **配套文件与 `SKILL.md` 放在同一目录。** 例如 `reviewer-prompt.md`、`references/*.md`；仅当内容超过约 100 行或需要复用时，才拆分为独立文件。
- **控制字数预算。** 入门或高频 skill 少于 200 词，其他 skill 少于 500 词。

## Agent skills

### Issue tracker

Issues and PRDs are tracked in this repository's GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

Triage uses the five default canonical labels. See `docs/agents/triage-labels.md`.

### Domain docs

Domain documentation uses the single-context layout. See `docs/agents/domain.md`.
