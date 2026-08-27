# 竞态处理

会并发发出的异步请求（搜索输入、Tab/筛选切换、分页联动等），旧响应可能在新响应之后返回并覆盖新结果。用 `takeLatest` 包裹异步函数，使只有最后一次调用的结果生效。

## 依赖来源

- 项目已安装 `@imyangyong/utils`（>= 9.6.0）或 `@yeepay/client-utils`（>= 5.0.0）时，从已有的包导入，不加装第二个。
- 已安装但版本低于门槛时，升级到满足门槛的最新版。
- 两者都没有时，安装 `@imyangyong/utils`。

## 用法

`takeLatest` 不 reject 被取代的旧调用，而是让它 resolve 为 `STALE`。每个调用点都必须判断 `STALE` 并丢弃，否则旧数据照样写入状态，等于没包裹。

```ts
import { STALE, takeLatest } from '@imyangyong/utils'

const fetchList = takeLatest(async (params: ListParams) => {
  return await api.getList(params)
})

async function loadList(params: ListParams) {
  const res = await fetchList(params)
  if (res === STALE)
    return
  list.value = res
}
```

## 完成标准

- 每个可能并发覆盖的异步请求都经 `takeLatest` 包裹。
- 每个被包裹函数的调用点都处理了 `STALE` 分支。
- `takeLatest` 的导入来源符合上述依赖来源规则。
