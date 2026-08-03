# 路径与扩展名“像前端”但 runtime 证据是 Node CLI:不得加载 frontend rubric,
# 不得产生浏览器专属 finding(XSS/SSR/a11y 等)。

setup() {
  init_repo
  cat > package.json <<'EOF'
{
  "name": "eval-cli",
  "private": true,
  "bin": { "tablefmt": "./components/table.jsx" }
}
EOF
  mkdir -p components
  cat > components/table.jsx <<'EOF'
#!/usr/bin/env node
// 终端 ASCII 表格格式化工具(纯 Node,无浏览器)。
function render(rows) {
  return rows.map((r) => "| " + r.join(" | ") + " |").join("\n");
}
const input = JSON.parse(process.argv[2] || "[]");
process.stdout.write(render(input) + "\n");
EOF
  commit_all "cli tool"
  echo '// 支持空输入' >> components/table.jsx
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。这是一个纯 Node CLI 工具,没有浏览器环境。
EOF
}

check() {
  assert_not_output 'XSS|innerHTML|SSR|hydration|ARIA|屏幕阅读|键盘导航' "非浏览器范围不得出现浏览器专属 finding"
  assert_output '结论.*(未发现阻塞问题|存在阻塞问题|证据不足)' "必须给出正常结论"
}
