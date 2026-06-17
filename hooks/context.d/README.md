# Ninja session-context modules

Every `*.md` here (except this README) is concatenated in filename-sort order and injected at SessionStart as `additionalContext`. Use these modules to record **standing preferences** that should be loaded at the start of every session — not per-turn reasoning, not skill internals (those belong in `SKILL.md`), not project-specific notes (those belong in `AGENTS.md` / `CLAUDE.md`).

## Naming convention

`NN-<slug>.md` — two-digit numeric prefix controls load order. Reserved ranges:

| Range | Purpose |
|---|---|
| `00–09` | Global preferences (apply to every skill / workflow). |
| `10–19` | Coding workflow (`coding-guidelines` and related). |
| `80–89` | Review workflow (`subagent-code-review`, `frontend-code-review`). |
| `90–99` | Experimental modules. |

Empty or unreadable files are silently skipped. This `README.md` is excluded from the payload by the hook script.

## Authoring guidance

- Keep modules short — every module is loaded into every session's context window.
- Frame the content as a **standing user directive**, not a soft preference. SessionStart-injected content carries the same authority as if the user had typed it in the current turn; agents with built-in "only when the user explicitly asks" heuristics will discount any softer framing and the module won't take effect.
- Be explicit about what the directive can override and what it can't:
  - **Overrides** the agent's internal heuristics and self-discretion (e.g. "only delegate when the user explicitly asks", "this change looks trivial so I'll skip the step").
  - **Does not override** harness-level permission prompts (e.g. "Allow this tool?") — surface them unchanged. Likewise, do not pretend a missing capability is present; when a tool genuinely isn't exposed, defer to the relevant skill's fallback rules.
- Use absolute language about scope ("this session", "future sessions") instead of relative ("this turn", "next time") — SessionStart is session-scoped, not turn-scoped.
- If a module instructs the model to do something the user can disable mid-session, document how the disable should be persisted (typically a `feedback`-type memory) — without persistence, the next SessionStart will reinstate the default and the disable is effectively lost.
