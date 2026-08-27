# until 错误元组

需要就地处理失败的 `await`，不写 try/catch 就无法区分成败。用 `until` 包裹 Promise 工厂，把结果转为 `[error, data]` 元组，以判断分支替代 try/catch。

## 依赖来源

- 项目已安装 `@imyangyong/utils`（>= 9.6.0）或 `@yeepay/client-utils`（>= 5.0.0）时，从已有的包导入，不加装第二个。
- 已安装但版本低于门槛时，升级到满足门槛的最新版。
- 两者都没有时，安装 `@imyangyong/utils`。

## 用法

`until` 接收 Promise 工厂而非 Promise 本身，工厂内同步抛错同样进入 error 分支。error 非 null 时 data 为 null，必须先判断 error 再使用 data；每个调用点都必须处理 error 分支，否则失败被静默吞掉，等于没包裹。

```ts
import { until } from '@imyangyong/utils'

async function loadUser(id: string) {
  const [error, user] = await until(() => api.getUser(id))
  if (error)
    return showToast('加载失败')
  this.user = user
}
```

失败需要向上传播，或多个 await 共享同一失败处理时，不用 `until`，直接 await 或用 try/catch。

## 完成标准

- 每个需要就地处理失败的 `await` 都经 `until` 包裹，替代同等范围的 try/catch。
- 每个 `until` 调用点都处理了 error 分支，data 只在 error 为 null 后使用。
- `until` 的导入来源符合上述依赖来源规则。
