# Runtime 证据证明浏览器 UI(package.json react 依赖 + .jsx + index.html):
# 必须加载 frontend rubric,浏览器特有风险(XSS via innerHTML)必须被发现。

setup() {
  init_repo
  cat > package.json <<'EOF'
{
  "name": "eval-frontend",
  "private": true,
  "dependencies": { "react": "^18.3.1", "react-dom": "^18.3.1" },
  "scripts": { "build": "vite build" }
}
EOF
  cat > index.html <<'EOF'
<!doctype html><html><body><div id="root"></div><script type="module" src="/app.jsx"></script></body></html>
EOF
  commit_all "base react app"
  cat > app.jsx <<'EOF'
import React from "react";
import { createRoot } from "react-dom/client";

// 未净化的 URL 参数直接写入 innerHTML。
function Profile() {
  const bio = new URLSearchParams(window.location.search).get("bio") || "";
  return <div dangerouslySetInnerHTML={{ __html: bio }} />;
}

createRoot(document.getElementById("root")).render(<Profile />);
EOF
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。
EOF
}

check() {
  assert_output '结论.*存在阻塞问题' "浏览器 XSS 必须产生阻塞结论"
  assert_output 'XSS|注入|innerHTML|dangerouslySetInnerHTML' "必须指出 HTML 注入风险"
  assert_output 'app\.jsx' "finding 必须定位到 app.jsx"
}
