---
name: coding-guidelines
description: 减少常见 LLM 编码错误的行为准则。在编写、修改、重构或审查代码时使用。
license: MIT
---

# 编码准则

用于减少常见 LLM 编码错误的行为准则，源自 [Andrej Karpathy 对 LLM 编码陷阱的观察](https://x.com/karpathy/status/2015883857489522876)。

**权衡（Tradeoff）：** 这些准则偏向谨慎而非速度。对于琐碎任务，请自行判断。

## 1. 编码前先思考（Think Before Coding）

**不要假设（assume）。不要掩盖困惑。把权衡（tradeoffs）说出来。**

实现前：
- 明确说明你的假设（assumptions）。如果不确定，就提问。
- 如果存在多种理解（interpretations），把它们列出来，不要默默选择其一。
- 如果存在更简单的做法，就说出来。在有必要时提出异议。
- 如果有不清楚的地方，就停下来。指出困惑所在。提问。

## 2. 简洁优先（Simplicity First）

**用能解决问题的最少代码。不要写推测性的东西（speculative work）。**

- 不添加超出请求范围的功能。
- 不为一次性代码创建抽象（abstractions）。
- 不添加未被要求的“灵活性”（flexibility）或“可配置性”（configurability）。
- 不为不可能发生的场景编写错误处理（error handling）。
- 如果你写了 200 行，而它本可以是 50 行，那就重写。

问问自己：“资深工程师会不会说这过度复杂了？”如果答案是会，就简化。

## 3. 精准修改（Surgical Changes）

**只改必须改的地方。只清理你自己造成的问题。**

编辑现有代码时：
- 不要“改进”相邻的代码、注释或格式。
- 不要重构（refactor）没有问题的东西。
- 匹配现有风格（existing style），即使你会用不同方式来写。
- 如果发现无关的死代码（dead code），提及它，不要删除它。

当你的修改造成孤立代码时：
- 移除因你的修改而变得未使用的导入、变量或函数。
- 除非被要求，否则不要移除原本就存在的死代码。

检验标准：每一行改动都应该能够直接追溯到用户的请求。

## 4. 目标驱动执行（Goal-Driven Execution）

**定义成功标准（success criteria）。循环推进，直到验证（verify）通过。**

把任务转化为可验证的目标：
- “添加校验” → “为无效输入编写测试，然后让测试通过”
- “修复 bug” → “编写一个能复现它的测试，然后让测试通过”
- “重构 X” → “确保重构前后测试都通过”

对于多步骤任务，说明一个简短计划：
```
1. [步骤] → 验证：[检查]
2. [步骤] → 验证：[检查]
3. [步骤] → 验证：[检查]
```

强成功标准能让你独立循环推进。弱标准（“让它能用”）需要不断澄清。

## 5. 实现后审查（Post-Implementation Review）

**写完代码不等于完成。先验证，再用独立上下文复审。**

**REQUIRED SUB-SKILL:** `code-review` — 实现后默认进入 implementation follow-up 并派发独立 reviewer。跳过条件、rubric 路由、fallback 与修复闭环均以该 skill 为准，不在此重复。

完成实现后：
- 运行与改动相关的测试、类型检查或 lint，汇总命令与结果。
- 调用上述 sub-skill 派发 review。
