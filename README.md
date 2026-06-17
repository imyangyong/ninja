# Ninja

[Yang Yong](https://github.com/imyangyong)’s Personalized AI Extension Suite.

## Installation

### Codex

Install this repository as a Codex plugin from GitHub:

**Step 1: Add the marketplace**

```bash
codex plugin marketplace add git@github.com:imyangyong/ninja.git --ref main
```

**Step 2: Install the plugin**

```bash
codex plugin add ninja@imyangyong
```

Then restart Codex or reload plugins.

### Claude Code

**Step 1: Add the marketplace**

```bash
/plugin marketplace add imyangyong/ninja
```

**Step 2: Install the plugin**

```bash
/plugin install ninja
```

After that, reload plugins:

```bash
/reload-plugins
```

## SKILLS

- frontend-code-review: 代码评审。
- subagent-code-review: 默认派发独立 subagent 审查改动，按文件类型路由 rubric，自动修复 Critical/Important。
- generate-commit-message: 生成符合项目规范的 commit message。
- coding-guidelines: 降低 LLM 写代码的常见错误：先思考再动手、保持简单、外科手术式改动、目标可验证。Fork from: [Karpathy Guidelines](https://x.com/karpathy/status/2015883857489522876).

## Hooks

Auto-loaded by Codex and Claude Code plugin discovery — no extra configuration required. `hooks/hooks.json` registers two events:

### `SessionStart` — inject standing preferences

Both harnesses consume the same `hookSpecificOutput.additionalContext` payload, so a single hook config and entry script serve both.

- `hooks/session-start` — entry script; concatenates modules under `hooks/context.d/` (sorted) and emits them as `additionalContext`.
- `hooks/context.d/*.md` — modular session-level preferences. See [`hooks/context.d/README.md`](hooks/context.d/README.md) for the naming convention and authoring guidance.

To add new session-level guidance, drop a new `NN-<slug>.md` under `hooks/context.d/`. To remove a module's effect, delete the file — no other code changes needed.

### `PreToolUse` — confirm dangerous Bash commands (macOS)

- `hooks/check-dangerous-commands` — fires on every `Bash` tool call; scans the command against a built-in rule list (`rm`, `DELETE FROM`, `DROP TABLE`, `TRUNCATE`, `shutdown`/`reboot`, `mkfs`/`fdisk`, `diskutil erase`, `dd of=/dev/…`, `curl|sh` patterns, `git push --force` to `main`/`master`).
- On a match, a macOS confirmation dialog (`osascript`) requests explicit approval. Approving exits `0` (allow); cancelling, or any environment without a GUI, exits `2` with the matched rules written to stderr so the agent is told why the call was blocked.
