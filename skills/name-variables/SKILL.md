---
name: name-variables
description: 当用户要求把自然语言描述的功能、属性、状态或业务概念转换为变量名，或询问某个变量该如何命名时使用。
---

# 变量命名

将输入的含义转换为程序开发中通用、清晰的变量名。

## 命名规则

1. 准确识别核心实体、属性、状态、单位和数据形态，再组合名称。
2. 默认使用小驼峰 `camelCase`；输入明确表示常量时，使用 `UPPER_SNAKE_CASE`。
3. 优先采用行业惯用术语和缩写，如 `delta`、`ctx`、`avg`、`offset`、`threshold`、`buffer`。仅在缩写广为人知且不会产生歧义时使用。
4. 保留有助于区分含义的限定词，去掉 `data`、`info` 等空泛词以及重复上下文。
5. 状态优先使用语义自然的布尔命名，如 `isLoggedIn`、`hasPermission`、`canRetry`；采用可直接判真的正向语义，如 `isEnabled`、`isLoggedOut`，避免 `isNotDisabled` 等否定叠加；集合使用复数或明确的集合后缀，如 `users`、`userList`。
6. 多个名称同样合理时，最多给出三个选项，并说明各自强调的语义或适用场景。

## 输出

直接返回变量名，不添加开场白。单一最佳选项只输出名称；多个选项使用“或”分隔，并附一句简短说明。

示例：

- `像素差异` → `pixelDelta` 或 `deltaPixel`（前者更符合“实体 + 度量”结构）
- `图片压缩质量` → `compressionQuality` 或 `imageCompressionQuality`（后者在缺少图片上下文时更明确）
- `最大重试次数（常量）` → `MAX_RETRY_COUNT`
