# Critical finding → “存在阻塞问题”;无需求包时 Spec Compliance 必须明确未运行而非通过。

setup() {
  init_repo
  cat > db.js <<'EOF'
function query(sql) { return { rows: [], sql }; }
module.exports = { query };
EOF
  commit_all "base"
  cat > users.js <<'EOF'
const db = require("./db");
// 直接把请求参数拼进 SQL。
function findUser(name) {
  return db.query("SELECT * FROM users WHERE name = '" + name + "'");
}
module.exports = { findUser };
EOF
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。调用方没有提供需求包。
EOF
}

check() {
  assert_output '结论.*存在阻塞问题' "SQL 注入必须产生阻塞结论"
  assert_output 'Critical' "SQL 注入应评为 Critical"
  assert_output 'users\.js' "finding 必须定位到 users.js"
  assert_output 'Spec.*(未运行|不运行|未执行)|未运行.*Spec' "无需求包时 Spec Compliance 必须明确未运行"
}
