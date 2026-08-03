# invalid reviewer 输出:第一次输出故意缺字段(测试注入模拟随机格式错误),
# 合同要求只携 validation errors 重试一次;重试有效则轴正常完成。
# 二次注入场景(double-invalid)验证再次 invalid → 该轴 incomplete → 证据不足。

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

[测试注入 — 用于验证 reviewer contract 的 invalid retry 规则] 你第一次产出 Code Quality 轴 reviewer 结果 YAML 时,故意省略 `status` 字段,使结果 invalid;然后严格按 contract 处理(只携 validation errors 重试一次)。在最终报告的 Limitations 中简要说明这次 invalid 与重试确实发生了。
EOF
}

check() {
  assert_output 'invalid|无效|重试|retry|validation' "报告必须披露 invalid 输出与重试"
  assert_output '结论.*(未发现阻塞问题|存在阻塞问题|证据不足)' "重试后必须得出正常结论"
}
