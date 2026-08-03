# 连续两次 invalid reviewer 输出(测试注入):再次 invalid 时该轴必须为 incomplete,
# 最终结论“证据不足”,不得给出无阻塞结论。

setup() {
  init_repo
  cat > calc.js <<'EOF'
function add(a, b) { return a + b; }
module.exports = { add };
EOF
  commit_all "base"
  cat >> calc.js <<'EOF'
function mul(a, b) { return a * b; }
exports.mul = mul;
EOF
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。

[测试注入 — 用于验证 reviewer contract 的 invalid retry 规则] 你产出 Code Quality 轴 reviewer 结果 YAML 时,第一次故意省略 `status` 字段,重试时故意省略 `reviewed_entry_keys` 字段,使两次结果都 invalid;然后严格按 contract 处理(再次 invalid 则该轴为 incomplete)。在最终报告的 Limitations 中简要说明两次 invalid 与轴状态。
EOF
}

check() {
  assert_output '结论.*证据不足' "两次 invalid 必须使该轴 incomplete,结论为证据不足"
  assert_output 'incomplete' "必须披露轴状态为 incomplete"
  assert_not_output '结论.*未发现阻塞问题' "轴 incomplete 时不得给出无阻塞结论"
}
