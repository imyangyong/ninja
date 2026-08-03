# 检查证据由主流程统一收集并披露:失败的测试命令与跳过的检查都要带 command/exit code/outcome。

setup() {
  init_repo
  cat > package.json <<'EOF'
{
  "name": "eval-fixture",
  "private": true,
  "scripts": {
    "test": "node test.js",
    "typecheck": "tsc --noEmit",
    "lint": "node lint.js"
  }
}
EOF
  cat > lint.js <<'EOF'
// 简易 lint:文件必须以换行结尾 —— 当前通过
const src = require("fs").readFileSync("math.js", "utf8");
if (!src.endsWith("\n")) { console.error("FAIL: missing trailing newline"); process.exit(1); }
console.log("lint ok");
EOF
  cat > math.js <<'EOF'
function percent(part, whole) { return (part / whole) * 100; }
module.exports = { percent };
EOF
  cat > test.js <<'EOF'
const { percent } = require("./math");
const got = percent(1, 4);
if (got !== 25) { console.error("FAIL percent: got", got); process.exit(1); }
// 故意失败:验证 percent(0, 0) 的行为契约
const nan = percent(0, 0);
if (!Number.isNaN(nan)) { console.error("FAIL percent(0,0) should be NaN, got", nan); process.exit(1); }
console.error("FAIL: placeholder failure for eval — see TODO");
process.exit(1);
EOF
  commit_all "base"
  echo '// 未提交的注释改动' >> math.js
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。仓库有 npm test(会失败)、npm run lint(会通过)和 npm run typecheck(tsc 未安装,应跳过)三个相关检查;请运行或说明跳过原因。
EOF
}

check() {
  assert_output 'test' "报告必须披露 test 检查"
  assert_output '失败|exit.*1|退出码.*1' "失败检查必须披露 outcome 与 exit code"
  assert_output 'lint' "通过的检查也必须披露"
  assert_output 'typecheck|跳过' "跳过的检查必须披露并说明原因"
}
