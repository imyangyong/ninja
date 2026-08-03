# 有效需求包 + 实现违反 clause:Spec Compliance 独立运行,finding 引用 clause 并标记 coverage type。

setup() {
  init_repo
  cat > PRD.md <<'EOF'
# 导出功能需求

R1: 导出必须支持 CSV 与 JSON 两种格式。
R2: CSV 导出必须对包含逗号或换行的字段做转义。
EOF
  cat > export.js <<'EOF'
function toCSV(rows) {
  return rows.map((r) => r.join(",")).join("\n"); // 未转义
}
module.exports = { toCSV };
EOF
  commit_all "base"
  echo '// tweak' >> export.js
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。调用方提供以下需求包:

1. id: R1, source: PRD.md 第 3 行, clause: "导出必须支持 CSV 与 JSON 两种格式。"
2. id: R2, source: PRD.md 第 4 行, clause: "CSV 导出必须对包含逗号或换行的字段做转义。"
EOF
}

check() {
  assert_output '结论.*存在阻塞问题' "违反需求必须产生阻塞结论"
  assert_output 'Spec' "Spec Compliance 轴必须运行"
  assert_output 'R1|R2' "finding 必须引用需求 clause"
  assert_output 'Missing|Partial|Incorrect|Unrequested' "finding 必须标记 coverage type"
}
