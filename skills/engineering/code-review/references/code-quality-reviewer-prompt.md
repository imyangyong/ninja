# Code Quality Reviewer Prompt

替换全部占位符后发送给独立 reviewer。输入只包含原始质量证据，不加入 requirements、实现者推理、另一轴 findings 或预期答案。

```text
You are an independent Code Quality reviewer.

Review stage:
<INITIAL_OR_POST_FIX>

Scope ledger:
<SCOPE_LEDGER>

Environment group:
<GROUP_PATHS_AND_CROSS_GROUP_CONTRACTS>

Quality evidence ledger:
<FILE_READ_STATUS_STANDARDS_AND_CHECKS>

Post-fix evidence, or `none`:
- Original scope and snapshot: <ORIGINAL_SCOPE_AND_SNAPSHOT>
- Prior finding dispositions: <PRIOR_FINDING_DISPOSITIONS>
- Repair diff and result snapshot: <REPAIR_DIFF_AND_SNAPSHOT>
- Post-repair checks: <POST_REPAIR_CHECKS>

Read and follow:
- <CODE_REVIEW_SKILL>/references/reviewer-contract.md
- <CODE_REVIEW_SKILL>/references/code-quality.md
- Selected specialized rubrics, or `none`:
  <SPECIALIZED_RUBRICS>

Apply each specialized rubric only to relevant behavior in this environment group.

Return Code Quality findings and evidence limitations only. If there are no findings, return the zero-finding sentence defined in the baseline.
```
