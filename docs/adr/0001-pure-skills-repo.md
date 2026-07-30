# 从多 harness plugin 套件改为纯 skills 仓库

Ninja 原本以 plugin 形式分发，为 Claude Code / Codex / Gemini / OpenCode 各维护一套 manifest，外加 `plugins/ninja -> ..`  symlink（指回仓库根目录，仅用于满足 codex 本地 marketplace 的 local path 引用）。2026-07-28 起改为纯 skills 仓库：只保留 `skills/`，通过 `npx skills add imyangyong/ninja` 安装（symlink 到 agent 的 skills 目录），删除全部 manifest、symlink、hooks 与各 harness 适配层，不做 MCP。

动机是摆脱私有 plugin 格式、简化维护：skills 是跨 harness 的开放标准，本仓库的 `skills/<name>/SKILL.md` 布局天然符合 `npx skills` 的发现约定，plugin 包装纯属冗余。曾考虑把 OpenCode 的 `ninja_skill` 工具做成 MCP server，但 skills 独立安装后 harness 会原生发现它们，该工具随之冗余；hooks（危险命令拦截、SessionStart 注入）在 MCP 协议中无对应物，也不可用 skill 表达，故放弃。

**已接受的损失：**

- 危险命令 macOS 弹窗拦截被删除，改由 harness 权限模式/允许列表兜底。
- SessionStart 强制注入"实现后必须派发 reviewer"的语义降级：该指令并入 `coding-guidelines` §5 与 `code-review`，只在 skill 被触发加载时生效，不再有每 session 强注。
- Codex / Gemini / OpenCode 不再受支持；若这些 harness 支持开放 skills 标准则可自然受益，但本仓库不为其维护任何适配。
