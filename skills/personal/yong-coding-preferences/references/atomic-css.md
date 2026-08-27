# 原子化 CSS

项目已配置原子化 CSS 时，优先使用项目支持的 Attributify Mode。

- 从依赖和配置文件确认 Attributify Mode 是否可用，并沿用项目现有语法。
- 对可直接表达的静态原子样式优先使用属性化写法。
- 动态 class、组件传入的 class、项目自定义 class，以及当前工具无法属性化表达的样式，沿用合适的 class 写法。
- 仅整理本次新增或实质修改的样式；保持无关代码稳定。

```vue
<div flex="~ col" items-center gap-4 p-4>
  <!-- ... -->
</div>
```

## 完成标准

每组新增或实质修改的原子化样式都已优先采用项目可用的 Attributify 写法。
