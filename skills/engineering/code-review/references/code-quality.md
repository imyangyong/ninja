# Code Quality Baseline

评估代码自身、公共契约与运行时风险，不判断需求是否完整实现。仓库规则和架构决策优先于本基线。

## Correctness and robustness

- 正常路径、错误路径和边界值是否符合代码声明与公共契约。
- null、空集合、零值、无效输入、异常和部分失败是否被正确建模。
- 异步流程是否存在竞态、过期结果覆盖、重复提交、取消或清理遗漏。
- 状态转换、资源生命周期、事务边界和错误传播是否完整。
- 调用方、公共 API、持久化数据和向后兼容是否被破坏。

## Security and privacy

- 不可信输入是否安全跨越注入、脚本、命令、路径和反序列化边界。
- 鉴权、授权及租户或资源所有权是否在可信边界执行。
- 密钥、token、个人数据和内部信息是否被记录、暴露或打包。
- 失败默认值是否 fail closed，客户端限制是否被误作可信控制。

## Architecture and domain fit

- 状态与行为是否由正确模块拥有，依赖方向是否符合仓库边界。
- 抽象是否服务当前行为，而不是 speculative generality。
- 术语、邻近设计和 ADR 是否保持一致。
- API、类型与模块接口是否隐藏实现细节并保持一致语义。

## Tests

- 测试是否在公共行为 seam 上验证真实结果，而不是 mock 自身或内部步骤。
- 新行为、回归路径和重要边界是否有与风险相称的覆盖。
- 异步测试是否确定，失败是否能证明行为真的损坏。
- 缺少测试仅在当前改动存在可说明的回归风险时形成 finding。

## Performance and resources

- 复杂度、请求数量、查询数量、渲染或序列化成本是否随现实输入失控。
- 文件、连接、定时器、监听器、订阅和任务是否在所有路径释放。
- 缓存、批处理、分页和并发控制是否保持正确性。

## Maintainability

- 名称是否表达领域意图，控制流和数据流是否容易验证。
- 一项知识是否散落在多个位置，导致未来修改容易漏改。
- 注释是否解释不可见约束与原因。
- 错误处理和可观测性是否让故障可定位且不泄露敏感信息。

## Code smells

发现时使用 `possible <smell>`，并解释当前改动为什么体现该 smell；项目明确选择优先于 smell 判断。适用名单：

Mysterious Name、Duplicated Code、Feature Envy、Data Clumps、Primitive Obsession、Repeated Switches、Shotgun Surgery、Divergent Change、Speculative Generality、Message Chains、Middle Man、Refused Bequest

没有 finding 时返回：「未发现需要行动的 Code Quality 问题。」
