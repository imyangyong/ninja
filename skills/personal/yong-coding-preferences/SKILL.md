---
name: yong-coding-preferences
description: 应用 Yong 的个人编码偏好。在实现、修改、重构或审查代码时使用。
---

# Yong 编码偏好

把以下偏好作为编码基线。用户对当前任务的明确要求和仓库内已有约定优先；在两者未规定时应用本 Skill。

## 执行流程

1. 先检查受影响文件及项目配置，识别使用的框架、原子化 CSS 工具和既有写法。
2. 按分支加载对应的领域偏好：
   - 改动涉及 Vue 页面组件 → 读取 `references/vue-template.md`
   - 项目使用原子化 CSS 且改动涉及样式 → 读取 `references/atomic-css.md`
   - 改动涉及会并发发出的异步请求（搜索输入、Tab/筛选切换、分页联动等）且旧响应可能覆盖新结果 → 读取 `references/race-condition.md`
   - 改动涉及 UI 实现且项目已有可复用组件 → 读取 `references/component-reuse.md`
   - 改动涉及需要就地处理失败的 `await`（不写 try/catch 就无法区分成败的场景）→ 读取 `references/until.md`
3. 只应用与本次改动相关的偏好，并保持未涉及代码稳定。
4. 完成后逐项检查所有新增或实质修改的代码；每条适用偏好均已落实或有项目约束作为例外。

## 完成标准

- 每个已加载领域偏好的完成标准均已满足。
- 代码符合项目现有格式化、类型检查和测试要求。
