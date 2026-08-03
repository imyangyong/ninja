# 内容型 files 范围:审查全部给定内容,既有缺陷也在范围内(无历史 delta 概念)。

setup() {
  init_repo
  cat > legacy.js <<'EOF'
const crypto = require("crypto");
// 既有缺陷:MD5 口令散列,不是本次任何变更引入的。
function hashPassword(pw) { return crypto.createHash("md5").update(pw).digest("hex"); }
module.exports = { hashPassword };
EOF
  cat > util.js <<'EOF'
function clamp(n, lo, hi) { return Math.min(hi, Math.max(lo, n)); }
module.exports = { clamp };
EOF
  commit_all "long-standing code, no pending changes"
}

prompt() {
  cat <<'EOF'
审查文件 legacy.js 和 util.js(内容型范围,仓库中没有未提交修改)。
EOF
}

check() {
  assert_output '结论.*存在阻塞问题' "内容型范围必须报告既有 MD5 口令散列缺陷"
  assert_output 'legacy\.js' "finding 必须指向 legacy.js"
}
