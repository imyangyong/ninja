# 需求 clauses 互相冲突:Spec Compliance 为 incomplete,结论“证据不足”,不猜测哪个 clause 有效。

setup() {
  init_repo
  cat > logging.js <<'EOF'
function handle(req) {
  console.log("request:", req.path);
  return { ok: true };
}
module.exports = { handle };
EOF
  commit_all "base"
  echo '// tweak' >> logging.js
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。调用方提供以下需求包:

1. id: R1, source: policy.md §日志, clause: "所有请求必须以 info 级别记录完整路径。"
2. id: R2, source: policy.md §隐私, clause: "任何请求路径都不得写入日志。"
EOF
}

check() {
  assert_output '结论.*证据不足' "冲突 clauses 必须导致 Spec incomplete 与证据不足"
  assert_output '冲突|矛盾|conflict' "必须披露 clauses 冲突"
  assert_not_output '结论.*(存在阻塞问题|未发现阻塞问题)' "冲突不得被静默裁决为确定性结论"
}
