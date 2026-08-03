# branch 范围:审查 feature 分支相对 merge-base 的 diff;main 上的既有代码不属于变更。

setup() {
  init_repo
  cat > auth.js <<'EOF'
function hash(pw) { return require("crypto").createHash("sha256").update(pw).digest("hex"); }
function verify(user, pw) { return user.pwHash === hash(pw); }
module.exports = { hash, verify };
EOF
  commit_all "base auth"
  git checkout -q -b feature/session
  cat > session.js <<'EOF'
const sessions = {};
// session token 可预测:仅基于用户名和时间戳秒。
function createSession(user) {
  const token = Buffer.from(user.name + Math.floor(Date.now() / 1000)).toString("base64");
  sessions[token] = user.name;
  return token;
}
module.exports = { createSession };
EOF
  commit_all "add sessions"
}

prompt() {
  cat <<'EOF'
审查当前分支 feature/session 相对 main 的修改。
EOF
}

check() {
  assert_output '结论.*存在阻塞问题' "可预测 session token 必须被发现"
  assert_output 'session\.js' "finding 必须指向分支引入的文件"
  assert_not_output 'auth\.js.*(Critical|Important)' "main 上的既有代码不应产生变更型 finding"
}
