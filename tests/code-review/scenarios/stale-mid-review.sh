# Mutable scope 在派发后被修改:聚合前复核必须判 stale,结论为“证据不足”。
# fixture 提供足够多的文件使审查耗时明显大于修改间隔;后台循环持续改动 worktree。

setup() {
  init_repo
  for i in 1 2 3 4 5 6 7 8; do
    { echo "// module $i: arithmetic helpers"; echo "function f$i(x) { return x + $i; }"; echo "module.exports = { f$i };"; } > "mod$i.js"
  done
  commit_all "base"
  # 制造一批未提交修改作为初始审查范围
  for i in 1 2 3 4 5 6 7 8; do
    echo "function g$i(x) { return x * $i; }" >> "mod$i.js"
    echo "exports.g$i = g$i;" >> "mod$i.js"
  done
  # 后台 mutator:审查进行期间持续改变 entry 内容身份与集合
  (
    n=0
    sleep 10
    while true; do
      n=$((n + 1))
      echo "// mutation $n during review" >> "mod$((n % 8 + 1)).js"
      if [ $((n % 3)) -eq 0 ]; then
        echo "module.exports = { v: $n };" > "late-new-file.js"
      fi
      sleep 5
    done
  ) &
  echo $! > .mutator.pid
}

teardown() {
  [ -f .mutator.pid ] && kill "$(cat .mutator.pid)" 2>/dev/null
  return 0
}

prompt() {
  cat <<'EOF'
审查当前修改(默认 worktree 范围)。
EOF
}

check() {
  assert_output '结论.*证据不足' "审查期间范围身份变化必须产生 stale,结论为证据不足"
}
