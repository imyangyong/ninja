# 需求 clause 的直接引用不可读:Spec Compliance 为 incomplete,结论“证据不足”,不得称为通过。

setup() {
  init_repo
  cat > feature.js <<'EOF'
function exportData(rows) { return rows.map((r) => r.join(",")).join("\n"); }
module.exports = { exportData };
EOF
  commit_all "base"
  echo '// tweak' >> feature.js
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。调用方提供以下需求包:

1. id: R1, source: SECURE-spec.pdf 第 2 页(该文件不存在于仓库), clause: "导出必须对所有字段做 RFC 4180 转义。"
EOF
}

check() {
  assert_output '结论.*证据不足' "需求来源不可读必须导致 Spec incomplete 与证据不足"
  assert_output 'SECURE-spec\.pdf|不可读|无法读取|不存在' "必须披露不可读的需求来源"
  assert_not_output '结论.*(存在阻塞问题|未发现阻塞问题)' "证据不足时不得给出确定性结论"
}
