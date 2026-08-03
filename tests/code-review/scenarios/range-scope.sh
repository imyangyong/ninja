# range 范围:base..result 解析为稳定 OIDs,审查 merge-base diff。

setup() {
  init_repo
  cat > store.js <<'EOF'
const data = {};
function set(k, v) { data[k] = v; }
function get(k) { return data[k]; }
module.exports = { set, get };
EOF
  commit_all "base store"
  cat > store.js <<'EOF'
const data = {};
function set(k, v) { data[k] = v; }
function get(k) { return data[k]; }
function clear() { for (const k in data) delete data[k]; }
module.exports = { set, get, clear };
EOF
  commit_all "add clear"
  cat > store.js <<'EOF'
const data = {};
function set(k, v) { data[k] = v; }
function get(k) { return data[k]; }
function clear() { for (const k in data) delete data[k]; }
// 原型链键被直接写入,__proto__ 会污染所有对象。
function importEntries(entries) {
  for (const k of Object.keys(entries)) data[k] = entries[k];
}
module.exports = { set, get, clear, importEntries };
EOF
  commit_all "add import"
}

prompt() {
  cat <<EOF
审查 range main~2..main 的修改。
EOF
}

check() {
  assert_output '结论.*存在阻塞问题' "range 内的原型污染风险必须被发现"
  assert_output 'importEntries|store\.js' "finding 必须指向 range 引入的代码"
}
