# Specialized Rubric Registry

本表只提供可验证的 evidence signals；AI 必须结合所选 diff、完整文件与模块边界做最终判断。通用 `code-quality.md` 始终生效，任何 specialized rubric 都不享有默认优先级。

## Selection process

1. 只从审查范围对应的快照读取文件、manifest、依赖和配置，避免被范围外工作区内容污染。
2. 按共同 manifest、构建边界、运行环境和调用关系把高度相关文件归为一个环境组。
3. 对每个候选 rubric 记录支持与冲突证据。至少一个 strong signal，或多个相互印证的 supporting signals，才加载 rubric。
4. 单一扩展名、目录名或工具配置不足以推断完整技术栈。证据冲突或不足时只用通用基线，并披露原因。
5. 一个环境组加载全部适用 rubrics，由一个 reviewer 综合审查。仅当运行环境与模块边界明显独立时拆分 reviewer。

## Registered rubrics

### frontend

**Path**: `rubrics/frontend.md`

**Strong signals**:

- 变更包含 Vue/Svelte/Astro 等组件文件。
- JSX/TSX 变更导入或使用 React、Preact、Solid、Qwik 等 UI runtime。
- manifest 声明浏览器 UI framework，且变更文件属于其浏览器入口、组件或页面。
- 变更直接操作 DOM、Web Components、浏览器事件或浏览器渲染 API。

**Supporting signals**:

- HTML/template、CSS/preprocessor、设计 token 或客户端资源发生变化。
- 前端 bundler、路由、状态管理、组件测试或 E2E 配置与相关代码一起变化。
- 明确的 web/client/ui 模块边界，且邻近代码确认其运行在浏览器。

**Not sufficient alone**:

- `.js`/`.ts`、`package.json`、Vite/Webpack 配置或目录名本身。
- 同构仓库中的 Node 脚本、服务端路由或构建工具代码。

## Extension contract

新增 specialized rubric 时：

1. 在本目录新增一个自包含 rubric 文件。
2. 在 “Registered rubrics” 增加名称、相对路径、strong signals、supporting signals 与易误判的反例。
3. 不修改主 `SKILL.md` 的选择流程。未来 rubric 与现有 rubric 地位相同，可在同一环境组共同加载。
