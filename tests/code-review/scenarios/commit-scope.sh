# 单个 commit 范围:解析为稳定 OID,只审查该 commit 的 diff。
# 目标 commit 引入 Critical bug;历史中其他 bug 不属于范围。

setup() {
  init_repo
  cat > calc.js <<'EOF'
function add(a, b) { return a + b; }
module.exports = { add };
EOF
  commit_all "add calc"
  cat > calc.js <<'EOF'
function add(a, b) { return a + b; }
// 除法不处理除零,直接返回 Infinity 进入金额计算。
function divideAmount(total, parts) { return total / parts; }
module.exports = { add, divideAmount };
EOF
  commit_all "add divide"
  cat > README.md <<'EOF'
# calc
EOF
  commit_all "docs"
}

prompt() {
  cat <<EOF
审查 commit $(git rev-parse HEAD~1) 这一个提交的修改。
EOF
}

check() {
  assert_output '结论.*存在阻塞问题' "目标 commit 的除零缺陷必须被发现"
  assert_output 'divideAmount|calc\.js' "finding 必须指向目标 commit 引入的代码"
  assert_not_output '\[CQ-[0-9]+\].*README' "范围外提交不得产生 finding"
}
