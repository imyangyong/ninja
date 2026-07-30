# Frontend Code Quality Rubric

仅在 registry 有充分前端证据时加载。根据证据适配实际框架与工具，不假设 Vue、React、Vite、状态管理、测试框架或包管理器。仓库规范优先，finding 使用通用 Critical / Important / Minor 定义与输出格式。

只报告当前改动中有现实触发条件的问题；不要把下列清单当成配额。

## Correctness and UI state

- loading、empty、error、success、disabled 与权限状态是否可达且互不矛盾。
- props、受控值、派生状态与本地副本是否保持单向数据流，避免陈旧或双重真相。
- 条件渲染、列表 key、表单默认值、零值与空字符串是否保持业务语义。
- effect/watch/subscription 是否使用正确依赖，并防止旧请求覆盖新结果或卸载后更新。
- timer、listener、observer、subscription、object URL 与请求是否在生命周期结束时清理或取消。

## Type safety and boundaries

- component props、events/callbacks、slots/children、refs 与 API 数据是否有准确类型。
- `any`、双重断言、ignore 指令或非空断言是否掩盖真实边界；只在产生现实风险时报告。
- 后端数据是否在进入 UI 状态前验证或收窄，discriminated union 是否完整处理。
- 类型与运行时默认值、可选性和框架实际行为是否一致。

## Components and state ownership

- 状态是否放在最低的共同所有者；局部状态不应无故进入全局 store。
- component、hook/composable 与 store 是否各自拥有清晰职责，避免跨边界修改内部状态。
- 公共组件 API 是否表达业务意图，避免泄漏特定页面实现或 speculative flexibility。
- 抽取建议应基于重复知识、独立生命周期或清晰边界，而不是机械行数阈值。

## Performance

- render/computed/selectors 是否在真实数据规模下重复执行昂贵工作。
- 列表、图片、bundle 与网络请求是否存在可证明的加载或内存风险。
- memoization、virtualization、debounce、pagination 或 code splitting 只有在当前负载需要时才建议。
- 修复性能问题不得引入陈旧闭包、错误缓存 key 或状态不同步。

## Tests

- 测试通过用户可观察行为验证组件，而不是断言内部 state、实现方法或 mock 自身。
- 新交互覆盖关键键盘/指针路径，以及 loading、empty、error 和异步竞态等相关边界。
- 异步测试等待可观察结果，不依赖固定 sleep。
- E2E 与 component/unit 测试放在能以最少 seam 证明行为的最高层。

## Security

- HTML 注入 API（如 `v-html` / `dangerouslySetInnerHTML`）不得接收未净化的不可信内容。
- 动态 URL、redirect、`href`、`src` 与下载内容需要适合上下文的 scheme/origin 校验。
- token、密钥、内部端点或敏感数据不得进入客户端 bundle、持久化存储或日志。
- 前端权限与路由守卫只改善 UX，不能被当作可信授权边界。
- `postMessage`、iframe、window opener 与跨域通信应验证来源和消息结构。

## Styles and assets

- 样式作用域、cascade 与 selector 是否会污染无关组件或被意外覆盖。
- 颜色、间距、层级和动效是否遵循仓库 design tokens 与主题机制。
- Tailwind/UnoCSS 等静态扫描器无法发现运行时拼接的 utility class；候选 class 应以完整静态字符串、映射或项目认可的 safelist 表达。
- 响应式布局应适应内容、缩放和目标 viewport，避免只对单一截图成立。
- 图片、字体与其他资源应使用正确尺寸、格式、加载策略和失败回退。

## Accessibility and internationalization

- 交互使用正确语义元素，支持键盘、焦点可见性和合理的 focus order。
- 表单 label、错误提示、dialog、动态状态与自定义控件具备可感知名称和关系。
- 图片 alt 与图标名称符合其信息/装饰用途；ARIA 不替代原生语义。
- 文案、复数、日期、数字、货币与布局不得假设单一语言或固定文本长度。
- 动画与颜色不应成为唯一信息载体，并尊重 reduced-motion 等用户偏好。

## Browser and framework integration

- 只使用目标浏览器与渲染模式支持的 API；SSR/hydration 路径不得直接依赖仅浏览器全局。
- framework lifecycle、事件、ref 与异步渲染语义应按实际版本判断。
- 动态 import、环境变量与客户端/服务端边界应符合项目 bundler 的静态分析规则。
- 命名与文件约定遵循仓库和实际 framework；不要强加跨项目通用的前缀或大小写偏好。
