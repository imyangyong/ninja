#!/usr/bin/env bash
# Fixture-driven eval runner for the code-review skill.
#
# Usage: tests/code-review/run.sh [scenario ...]
#   No arguments runs every scenarios/*.sh. Each scenario is invoked as a
#   complete skill call against a controlled fixture and asserted only on
#   externally visible results (axis statuses, findings, limitations,
#   checks, conclusion).
#
# Env:
#   MAX_JOBS           parallel scenarios (default 3)
#   CLAUDE_EXTRA_ARGS  extra args for the headless claude invocation
#   KEEP_FIXTURES=0    delete fixture dirs after the run (default: keep)
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
results="$here/.results"
mkdir -p "$results"
rm -f "$results"/*.status "$results"/*.log 2>/dev/null

if [ "$#" -gt 0 ]; then
  names="$@"
else
  names="$(cd "$here/scenarios" && ls *.sh | sed 's/\.sh$//')"
fi

MAX_JOBS="${MAX_JOBS:-3}"

run_one() {
  local name="$1"
  local src="$here/scenarios/$name.sh"
  if [ ! -f "$src" ]; then
    echo "no such scenario: $name"
    echo 2 > "$results/$name.status"
    return
  fi
  local tmp log prompt_file
  tmp="$(mktemp -d /tmp/code-review-eval.XXXXXX)"
  log="$results/$name.log"
  prompt_file="$tmp/.prompt"
  (
    set -e
    source "$here/lib.sh"
    source "$src"
    cd "$tmp"
    setup
    review_prompt "$(prompt)" > "$prompt_file"
    run_review "$prompt_file" "$log" || true
    LOG="$log"
    check
    echo "$ASSERT_FAILURES" > "$tmp/.failures"
    if type teardown >/dev/null 2>&1; then teardown; fi
    true
  )
  local rc=$?
  local failures=1
  [ -f "$tmp/.failures" ] && failures="$(cat "$tmp/.failures")"
  if [ "$rc" -eq 0 ] && [ "$failures" -eq 0 ]; then
    echo "PASS $name (log: $log, fixture: $tmp)"
    echo 0 > "$results/$name.status"
  else
    echo "FAIL $name (log: $log, fixture: $tmp)"
    echo 1 > "$results/$name.status"
  fi
  if [ "${KEEP_FIXTURES:-1}" = "0" ]; then
    chmod -R u+rwX "$tmp" 2>/dev/null
    rm -rf "$tmp"
  fi
}

running=0
for name in $names; do
  while [ "$(jobs -rp | wc -l)" -ge "$MAX_JOBS" ]; do
    sleep 1
  done
  run_one "$name" &
done
wait

failed=0
for name in $names; do
  if [ ! -f "$results/$name.status" ] || [ "$(cat "$results/$name.status")" != "0" ]; then
    failed=$((failed + 1))
  fi
done

echo "-----"
if [ "$failed" -eq 0 ]; then
  echo "all scenarios passed"
else
  echo "$failed scenario(s) failed"
fi
exit "$failed"
