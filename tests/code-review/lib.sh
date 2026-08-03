#!/usr/bin/env bash
# Shared helpers for code-review eval scenarios.
# Sourced by run.sh inside each scenario's fixture directory.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/skills/engineering/code-review"

# --- fixture helpers ---------------------------------------------------------

init_repo() {
  git init -q -b main .
  git config user.email eval@example.com
  git config user.name eval
  git config commit.gpgsign false
}

commit_all() {
  git add -A
  git commit -q -m "${1:-commit}"
}

# --- review invocation -------------------------------------------------------

# review_prompt <scope description...>
# Builds the standard prompt: read the worktree skill (never any installed
# skill of the same name) and review the given scope exactly per contract.
review_prompt() {
  cat <<EOF
你是 code review 执行器。首先阅读 $SKILL_DIR/SKILL.md 以及它引用的全部 references 文件（包括 rubrics）。严格且仅按照这些文件定义的流程、合同与输出格式执行；不要使用任何已安装的同名 skill 或你记忆中的其他审查协议。

审查范围与输入如下：

$1

只输出 skill output format 定义的最终报告（结论/方式/范围/检查/Findings/Limitations 等），不要输出其他解释。
EOF
}

# run_review <prompt-file> <log-file>
# Runs headless claude; one retry when the CLI itself crashes (nonzero exit
# AND empty log), plus backoff retries on provider quota/rate-limit errors.
# Returns claude's exit code of the final attempt.
run_review() {
  local prompt_file="$1" log="$2"
  local attempt=1
  while [ "$attempt" -le 4 ]; do
    : > "$log"
    claude -p "$(cat "$prompt_file")" --dangerously-skip-permissions ${CLAUDE_EXTRA_ARGS:-} > "$log" 2>&1
    local rc=$?
    if grep -qiE "usage limit|rate.?limit|Failed to authenticate|overloaded|429|503" "$log"; then
      echo "(attempt $attempt: provider quota/rate limit, backing off)"
      sleep $((attempt * 45))
      attempt=$((attempt + 1))
      continue
    fi
    if [ "$rc" -ne 0 ] && [ ! -s "$log" ] && [ "$attempt" -lt 4 ]; then
      echo "(attempt $attempt: claude CLI crashed, retrying)"
      attempt=$((attempt + 1))
      continue
    fi
    return "$rc"
  done
}

# --- assertions --------------------------------------------------------------

ASSERT_FAILURES=0

assert_output() {
  # assert_output <extended-regex> <description>
  if grep -qE "$1" "$LOG"; then
    return 0
  fi
  echo "ASSERT FAIL: expected output to contain /$1/ — $2"
  ASSERT_FAILURES=$((ASSERT_FAILURES + 1))
}

assert_not_output() {
  # assert_not_output <extended-regex> <description>
  if ! grep -qE "$1" "$LOG"; then
    return 0
  fi
  echo "ASSERT FAIL: expected output NOT to contain /$1/ — $2"
  ASSERT_FAILURES=$((ASSERT_FAILURES + 1))
}
