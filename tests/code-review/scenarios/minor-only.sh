# 仅 Minor finding:结论保持“未发现阻塞问题”,Minor 必须列出且带具体维护成本。

setup() {
  init_repo
  cat > config.js <<'EOF'
module.exports = { retries: 3 };
EOF
  commit_all "base"
  cat > api.js <<'EOF'
// 三处重复的魔法超时常量,含义相同却各自维护(变更新增)。
const TIMEOUT_MS = 5000;
function fetchOrder(id) { return request("/orders/" + id, { timeout: 5000 }); }
function fetchUser(id) { return request("/users/" + id, { timeout: 5000 }); }
function request(url, opts) { return { url, opts }; }
module.exports = { fetchOrder, fetchUser, TIMEOUT_MS };
EOF
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。改动只有 api.js 这个新文件。
EOF
}

check() {
  assert_output '结论.*未发现阻塞问题' "仅 Minor 时结论必须为未发现阻塞问题"
  assert_output 'Minor' "Minor finding 必须列出"
  assert_not_output '结论.*存在阻塞问题' "Minor 不得升级为阻塞结论"
}
