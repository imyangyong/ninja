# Ninja

[Yang Yong](https://github.com/imyangyong)’s Personalized AI Extension Suite.

## Installation

### Codex

Install this repository as a Codex plugin from GitHub:

**Step 1: Add the marketplace**

```bash
codex plugin marketplace add git@github.com:imyangyong/ninja.git --ref main
```

**Step 2: Install the plugin**

```bash
codex plugin add ninja@imyangyong
```

Then restart Codex or reload plugins.

### Claude Code

**Step 1: Add the marketplace**

```bash
/plugin marketplace add imyangyong/ninja
```

**Step 2: Install the plugin**

```bash
/plugin install ninja
```

After that, reload plugins:

```bash
/reload-plugins
```

## SKILLS

- frontend-code-review: 代码评审。
- generate-commit-message: 生成符合项目规范的 commit message。
- clarify-before-coding: 在 coding 任务前先发现并确认模糊需求。
