# Frontend Code Quality Rubric

这是浏览器 UI 环境相对通用 Code Quality baseline 的增量检查，按实际 framework、版本、bundler 和渲染模式套用。

## UI state and lifecycle

- loading、empty、error、success、disabled 与权限状态是否可达且语义一致。
- props、受控值、派生状态与本地副本是否产生陈旧状态或双重真相。
- 条件渲染、列表 key、表单默认值、零值与空字符串是否保持业务语义。
- effect、watch、subscription 与请求是否按实际 lifecycle 取消或清理。

## Browser boundaries

- SSR/hydration 路径是否在服务端访问 browser-only globals，或产生服务端与客户端结构差异。
- 动态 import、环境变量和客户端/服务端边界是否符合 bundler 的静态分析规则。
- HTML 注入 API 是否接收未经适当净化的不可信内容。
- 动态 URL、redirect、`href`、`src` 和下载内容是否验证适合上下文的 scheme/origin。
- `postMessage`、iframe、window opener 与跨域通信是否验证来源和消息结构。
- token、密钥、内部端点与敏感数据是否进入客户端 bundle、持久化存储或日志。

## Interaction and accessibility

- 交互是否使用正确语义元素，并支持键盘、可见焦点和合理 focus order。
- 表单 label、错误提示、dialog、动态状态与自定义控件是否具有可感知名称和关系。
- 图片 alt、图标名称和 ARIA 是否匹配其信息或装饰用途。
- 颜色或动画是否成为唯一信息载体，动效是否尊重 reduced-motion。

## Styles, content and assets

- 样式作用域、cascade 和 selector 是否污染无关组件或被意外覆盖。
- design tokens、主题机制与 utility-class 静态扫描约束是否得到遵守。
- 布局是否适应目标 viewport、内容变化、缩放与本地化文本长度。
- 文案、复数、日期、数字和货币是否使用项目国际化机制。
- 图片、字体与客户端资源是否具有与现实负载匹配的尺寸、格式、加载和失败策略。

## Framework behavior and tests

- props、events/callbacks、slots/children、refs 与 API 数据类型是否匹配实际 runtime 默认值和可选性。
- framework lifecycle、事件、ref、异步渲染和状态所有权是否符合所用版本。
- UI 测试是否覆盖相关的键盘或指针路径，以及 loading、empty、error 和异步竞态。
- 异步测试是否等待可观察结果，而不是依赖固定 sleep。
