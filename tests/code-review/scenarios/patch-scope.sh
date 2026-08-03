# patch 范围只绑定用户提供的原始 bytes:仓库中有同名文件但内容无关,
# 审查不得从仓库猜测 preimage 或上下文;patch 内的 Critical bug 必须被发现。

setup() {
  init_repo
  # 同名但内容无关的仓库文件 —— 不是 patch 的 preimage
  cat > server.js <<'EOF'
console.log("unrelated placeholder, not the patch preimage");
EOF
  commit_all "unrelated repo state"
}

prompt() {
  cat <<'EOF'
审查以下 patch(用户提供的原始 bytes;仓库中只有同名但无关的文件,不得从仓库猜测缺失的 preimage 或上下文):

```diff
--- a/server.js
+++ b/server.js
@@ -0,0 +1,12 @@
+const http = require("http");
+const { execSync } = require("child_process");
+
+const server = http.createServer((req, res) => {
+  const url = new URL(req.url, "http://localhost");
+  if (url.pathname === "/run") {
+    const out = execSync("sh -c " + url.searchParams.get("cmd"));
+    res.end(out);
+  }
+});
+server.listen(8080);
```
EOF
}

check() {
  assert_output '结论.*存在阻塞问题' "patch 中的远程命令注入必须被发现"
  assert_output 'server\.js' "finding 必须指向 patch 中的文件"
  assert_not_output 'unrelated placeholder' "不得从仓库猜测 patch 之外的内容"
}
