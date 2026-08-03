# Code Review 评测 seam

对完整 code-review skill 的 fixture 驱动行为评测：每个场景在一个受控 fixture 仓库或用户供给内容上，通过 headless `claude` 调用一次完整 skill（读取仓库 worktree 中的 `skills/engineering/code-review/`，而非任何已安装副本），只断言外部可见结果——轴状态、findings、limitations、检查披露与结论。

## 运行

```bash
tests/code-review/run.sh                 # 全部场景
tests/code-review/run.sh blocking-bug    # 单个场景
MAX_JOBS=4 tests/code-review/run.sh      # 并行度
```

日志写入 `.results/<scenario>.log`,fixture 保留在 `/tmp/code-review-eval.*` 供调试(`KEEP_FIXTURES=0` 可清除)。退出码为失败场景数。

## 场景约定

`scenarios/<name>.sh` 是被 source 的 bash，定义三个函数：

- `setup` — 在空 fixture 目录中构建受控仓库或供给内容;
- `prompt` — 输出用户请求（范围声明、需求包等），由 `lib.sh` 包成标准执行提示;
- `check` — 用 `assert_output` / `assert_not_output` 对报告文本做行为断言。

断言针对行为结果，不针对措辞、文件布局或 prompt 组成。

## 已知边界

- **PR scope** 需要真实 provider identity,fixture 无法本地构造；其 OID 解析与 diff 语义与 branch scope 相同，由 `branch-scope` 间接覆盖。
- **invalid-retry** 的 reviewer 输出错误是随机的，无法从外部确定性触发；场景通过测试注入诱发一次 invalid 输出，验证一次重试与二次 invalid 的合同行为真实发生。
- `stale-mid-review` 依赖审查期间的真实并发修改，时序上存在固有抖动。
