# Ninja — Agent Instructions

This repo provides skills that shape coding-agent behavior. Each skill lives at `skills/<name>/SKILL.md` and is consumed via your harness's skill mechanism (`Skill` tool in Claude Code, `$skill-name` in Codex, `activate_skill` in Gemini CLI, etc.).

## Skills (with triggers)

| Skill | Trigger conditions |
|---|---|
| `ninja:coding-guidelines` | Starting any non-trivial implementation / refactor / review; vague spec with "just code it"; "先想一下" / "保持简单" moments. |
| `ninja:subagent-code-review` | A non-trivial change just finished; user says "review my changes" / "看一下刚改的" / "post-implementation review"; required by `ninja:coding-guidelines` §5. |
| `ninja:frontend-code-review` | User requests frontend code review (Vue / React / TypeScript); "review 一下" / "PR review" / "帮我看看这段代码"; loaded by `ninja:subagent-code-review` when changed files are frontend. |
| `ninja:generate-commit-message` | User asks to write a commit message / commit code; pastes a diff and asks to summarize into one commit. |

## Invocation Discipline

Before responding to a user message:

1. Scan for any trigger above.
2. If any plausibly applies (even with low confidence), load the skill **before** taking other action.
3. Rationalizations like "this is just a simple question" or "I'll gather context first" are red flags — load the skill first, then act.

## Skill Authoring Conventions

If you are editing or adding a skill in this repo:

- **Frontmatter `description` = trigger conditions only.** Never put workflow steps in the description — when the description summarizes workflow, agents follow the description and skip the body.
- **Cross-skill dependencies use explicit markers.** Inline at the relevant section:
  - `**REQUIRED SUB-SKILL:** ninja:<name>` — called from this skill.
  - `**REQUIRED BACKGROUND:** ninja:<name>` — context the agent must already know.
  - Avoid `@` syntax — it force-loads files and burns context.
- **Supporting files live next to `SKILL.md`** (`reviewer-prompt.md`, `references/*.md`). Create separate files only when content exceeds ~100 lines or is reused.
- **Word budget guidance**: getting-started / frequently-loaded skills < 200 words; others < 500 words.
