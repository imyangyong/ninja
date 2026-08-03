# snippet 缺失上下文:只审查给定 bytes,披露缺失上下文为 limitation,
# 不从仓库状态猜测;缺失不阻止关键判断时结论可以干净。

setup() {
  init_repo
  # 仓库里恰好有同名函数,但 snippet 审查不得用它“补全”上下文
  cat > helpers.js <<'EOF'
function sanitize(s) { return s; } // 仓库版本其实不转义 —— 与 snippet 无关
module.exports = { sanitize };
EOF
  commit_all "repo with same-named helper"
}

prompt() {
  cat <<'EOF'
审查以下 snippet(用户提供的原始 bytes;上下文不完整,不得从仓库猜测):

```js
function renderComment(comment) {
  const el = document.createElement("div");
  el.innerHTML = sanitize(comment.body);
  return el;
}
```
EOF
}

check() {
  assert_output 'sanitize|上下文|context' "必须指出 sanitize 行为未知这一缺失上下文或其后果"
  assert_not_output 'helpers\.js' "不得引用仓库中的同名文件来补全上下文"
}
