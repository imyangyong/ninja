# “当前修改”必须覆盖 staged、unstaged、untracked 与 deleted entries。
# 关键证据:唯一的 Critical bug 位于 untracked 文件 —— 静默跳过它就必须改变结论。

setup() {
  init_repo
  cat > alpha.js <<'EOF'
function add(a, b) { return a + b; }
module.exports = { add };
EOF
  cat > beta.js <<'EOF'
function greet(name) { return "hello " + name; }
module.exports = { greet };
EOF
  cat > doomed.js <<'EOF'
module.exports = { legacy: true };
EOF
  commit_all "base"

  # unstaged 修改
  cat > alpha.js <<'EOF'
function add(a, b) { return a + b; }
function sub(a, b) { return a - b; }
module.exports = { add, sub };
EOF
  # staged 修改
  cat > beta.js <<'EOF'
function greet(name) { return "hi " + name; }
module.exports = { greet };
EOF
  git add beta.js
  # untracked 文件,含唯一 Critical bug
  cat > gamma.js <<'EOF'
const { execSync } = require("child_process");
// 直接把未校验的用户输入拼进 shell 命令。
function lookup(host) {
  return execSync("ping -c 1 " + host).toString();
}
module.exports = { lookup };
EOF
  # deleted 文件
  git rm -q doomed.js
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。
EOF
}

check() {
  assert_output '结论.*存在阻塞问题' "untracked gamma.js 中的命令注入必须被发现"
  assert_output 'gamma\.js' "untracked entry 必须出现在报告中"
  assert_output 'Critical' "命令注入应评为 Critical"
  assert_not_output '结论.*未发现阻塞问题' "覆盖完整时不可能是干净结论"
}
