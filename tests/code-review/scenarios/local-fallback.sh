# 需求包 + delegation 不可用:本地回退必须披露,先冻结 Code Quality 再执行 Spec,语义不变。

setup() {
  init_repo
  cat > PRD.md <<'EOF'
# 需求

R1: 删除操作必须要求二次确认。
EOF
  cat > delete.js <<'EOF'
// 直接删除,无任何确认。
function deleteAccount(id) { return db.destroy("accounts", id); }
module.exports = { deleteAccount };
EOF
  commit_all "base"
  echo '// tweak' >> delete.js
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。本环境不支持 delegation:不要派发任何 subagent/Task,按 skill 的本地回退依次执行审查轴,并披露本地回退。调用方提供以下需求包:

1. id: R1, source: PRD.md 第 3 行, clause: "删除操作必须要求二次确认。"
EOF
}

check() {
  assert_output '本地回退|local fallback|回退' "必须披露本地回退"
  assert_output '结论.*存在阻塞问题' "Missing 需求必须产生阻塞结论"
  assert_output 'R1' "finding 必须引用需求 clause"
  assert_output 'Missing' "未实现的需求必须标记 Missing"
}
