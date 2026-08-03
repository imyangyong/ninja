#!/usr/bin/env bash
# 引用一致性格式检查:证明仓库没有残留旧协议的术语、断链或缺失的单一真相来源。
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
failures=0

fail() { echo "LINT FAIL: $1"; failures=$((failures + 1)); }

# 1. 活跃文档与调用方不得引用已删除的协议或模块。
stale_pattern='implementation[ -]follow-up|post-fix|environment group|integration group|requirements-policy|code-quality-reviewer-prompt|spec-reviewer-prompt|reviewer-prompt\.md'
hits="$(grep -rniE "$stale_pattern" "$root/skills" "$root/README.md" "$root/CLAUDE.md" "$root/CONTEXT.md" "$root/docs/agents" 2>/dev/null || true)"
if [ -n "$hits" ]; then
  fail "stale protocol references:\n$hits"
fi

# 2. code-review skill 内的相对链接必须可解析。
check_links() {
  local file="$1" dir link target
  dir="$(dirname "$file")"
  grep -oE '\]\(([^)#]+)(#[^)]*)?\)' "$file" | sed -E 's/^\]\(([^)#]+)(#[^)]*)?\)$/\1/' | while read -r link; do
    case "$link" in
      http*|/*) continue ;;
    esac
    target="$dir/$link"
    if [ ! -e "$target" ]; then
      echo "LINT FAIL: broken link in $file: $link"
    fi
  done
}
link_failures="$({ for f in "$root/skills/engineering/code-review/SKILL.md" "$root"/skills/engineering/code-review/references/*.md "$root"/skills/engineering/code-review/references/rubrics/*.md; do check_links "$f"; done; } || true)"
if [ -n "$link_failures" ]; then
  echo "$link_failures"
  failures=$((failures + $(echo "$link_failures" | grep -c LINT)))
fi

# 3. 已删除模块必须不存在,保留模块必须存在。
for gone in requirements-policy implementation-follow-up code-quality-reviewer-prompt spec-reviewer-prompt; do
  [ -e "$root/skills/engineering/code-review/references/$gone.md" ] && fail "deleted module still present: $gone.md"
done
for kept in code-quality spec-compliance reviewer-contract output-format snapshot-protocol rubrics/frontend; do
  [ -e "$root/skills/engineering/code-review/references/$kept.md" ] || fail "expected module missing: $kept.md"
done

# 4. 术语与架构理由的单一真相必须存在。
[ -e "$root/CONTEXT.md" ] || fail "project glossary CONTEXT.md missing"
[ -e "$root/docs/adr/0002-evidence-bounded-code-review.md" ] || fail "evidence-bounded ADR missing"

if [ "$failures" -eq 0 ]; then
  echo "consistency checks passed"
else
  echo "$failures consistency check(s) failed"
fi
exit "$failures"
