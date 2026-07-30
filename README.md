# Ninja

[Yang Yong](https://github.com/imyangyong)’s Personalized AI Extension Suite.

## Installation

通过 [skills](https://github.com/vercel-labs/skills) CLI 安装（默认 symlink 到 agent 的 skills 目录）：

```bash
npx skills add imyangyong/ninja
```

常用选项：

```bash
# 只装某个 skill
npx skills add imyangyong/ninja --skill coding-guidelines

# 全局安装（用户目录而非当前项目）
npx skills add imyangyong/ninja -g

# 复制而非 symlink
npx skills add imyangyong/ninja --copy

# 列出本仓库可用的 skills
npx skills add imyangyong/ninja --list
```

## Skills

- coding-guidelines: 降低 LLM 写代码的常见错误：先思考再动手、保持简单、外科手术式改动、目标可验证。Fork from: [Karpathy Guidelines](https://x.com/karpathy/status/2015883857489522876).
- code-review: 通用代码审查入口；按实际代码环境加载专项 rubric，独立检查质量与需求合规，并在实现后闭环修复。
- generate-commit-message: 生成符合 Conventional Commits 规范的提交消息。
- name-variables: 把自然语言描述转换为变量名。
- translate-zh-en: 中英互译、单词读音/释义/例句、英文拼写纠正。

## 设计决策

本仓库曾是多 harness plugin 套件，2026-07 起改为纯 skills 仓库——见 [docs/adr/0001-pure-skills-repo.md](docs/adr/0001-pure-skills-repo.md)。贡献指南见 [CLAUDE.md](CLAUDE.md)。
