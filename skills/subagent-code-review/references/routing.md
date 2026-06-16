# Rubric 路由细则

每个改动文件先分类（前端 / 非前端 / 配置），再按下表互斥路由。

| 情形 | 处理 |
|---|---|
| **全部**文件是前端 | 一个 reviewer，rubric = `ninja:frontend-code-review` |
| **全部**文件是非前端 | 一个 reviewer，rubric = 内置通用 rubric |
| **混合**（既有前端也有非前端） | 派发**两个** reviewer，各自只审对应类型的文件列表 |
| 只有配置文件 | 一个 reviewer，rubric = 内置通用 rubric |

判定主观不确定时（命名模糊、跨界）按"混合"处理——多派一个 reviewer 比走错 rubric 安全。

## 前端判定

**(1) 按扩展名直接判前端**：`.vue`, `.tsx`, `.jsx`, `.svelte`, `.astro`, `.css`, `.scss`, `.sass`, `.less`, `.html` → 前端，结束。

**(2) 扩展名为 `.ts`, `.js`, `.mjs`, `.cjs`**：扫描路径段，按**最先出现**的判别段决定：

- 前端段：`components/`, `pages/`, `views/`, `web/`, `frontend/`, `client/`
- 非前端段：`server/`, `api/`, `backend/`, `worker/`, `cli/`, `scripts/`, `node_modules/`

最先出现的判别段决定归属。**没有匹配到任何段** → 按非前端处理（默认值）。

### 冲突示例

| 路径 | 最先出现的判别段 | 判定 |
|---|---|---|
| `client/api/users.ts` | `client/` | 前端（前端 API client 封装） |
| `apps/web/api/handlers.ts` | `web/` | 前端 |
| `server/web-bff/router.ts` | `server/` | 非前端 |
| `packages/api/src/client.ts` | `api/` | 非前端 |
| `packages/shared/utils.ts` | （无） | 非前端（默认） |

## 配置文件

不计入路由判定，但会随对应类型的 reviewer 一起审：

`vite.config.*`, `vue.config.*`, `webpack.config.*`, `tsconfig.*`, `package.json`, `pnpm-lock.yaml`, `.eslintrc.*`, `tailwind.config.*`, `postcss.config.*`

如果改动**只有**配置文件，按通用 rubric。
