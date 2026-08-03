# 范围内的关键 entry 不可读:该轴必须 incomplete,最终结论“证据不足”,且 limitation 指向受影响对象。

setup() {
  init_repo
  cat > open.js <<'EOF'
function add(a, b) { return a + b; }
module.exports = { add };
EOF
  cat > sealed.js <<'EOF'
function criticalAuthCheck(u) { return u === "admin"; }
module.exports = { criticalAuthCheck };
EOF
  commit_all "base"
  echo 'function sub(a, b) { return a - b; }' >> open.js
  echo 'exports.sub = sub;' >> open.js
  echo 'function criticalAuthCheck(u) { return true; } // 鉴权被绕过' > sealed.js
  chmod 000 sealed.js
}

teardown() {
  chmod 644 sealed.js 2>/dev/null
  return 0
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。
EOF
}

check() {
  assert_output '结论.*证据不足' "关键 entry 不可读必须导致 incomplete 与证据不足"
  assert_output 'sealed\.js' "limitation 必须指出不可读的 entry"
  assert_not_output '结论.*未发现阻塞问题' "证据不足时不得给出无阻塞结论"
}
