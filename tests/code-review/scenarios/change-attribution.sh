# 变更型归因:同文件中的既有缺陷(未触碰)不得成为 finding;变更引入的问题必须报告。

setup() {
  init_repo
  cat > app.js <<'EOF'
const crypto = require("crypto");
// 既有缺陷(不在本次变更内):弱口令散列。
function legacyStorePassword(pw) { return crypto.createHash("md5").update(pw).digest("hex"); }

function formatName(u) { return u.first + " " + u.last; }
module.exports = { legacyStorePassword, formatName };
EOF
  commit_all "base with pre-existing defect"
  # 本次变更:只改 formatName,并引入一个新的 Important bug(空串比较被 == 弱化)
  cat > app.js <<'EOF'
const crypto = require("crypto");
// 既有缺陷(不在本次变更内):弱口令散列。
function legacyStorePassword(pw) { return crypto.createHash("md5").update(pw).digest("hex"); }

function formatName(u) {
  if (u.id == "") return "anonymous"; // 变更引入:== 使 id=0 的用户也被判匿名
  return u.first + " " + u.last;
}
module.exports = { legacyStorePassword, formatName };
EOF
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。
EOF
}

check() {
  assert_output 'formatName' "变更引入的问题必须报告"
  assert_not_output '\[CQ-[0-9]+\].*legacyStorePassword' "变更未触碰的既有缺陷不得成为 finding(可作为 limitation 披露)"
  assert_not_output '\[CQ-[0-9]+\].*(md5|MD5)' "既有弱散列不得成为 finding(可作为 limitation 披露)"
}
