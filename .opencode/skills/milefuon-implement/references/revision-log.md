# Revision Log — milefuon-implement

Format for `milefuon/tracks/<track_id>/revisions.md`.

## When to Create

When the Issue Decision Tree (§4.4 d5) classifies an issue as **Spec Issue** or **Plan Issue**, create a revision entry before fixing.

## Entry Format

```markdown
## Revision N - YYYY-MM-DD - Type: Spec | Plan | Both

- **Triggered by:** <what went wrong — test failure, missing requirement, wrong order, etc.>
- **Location:** Phase <N> Task <M>: <task_name>
- **Classification:** Spec Issue | Plan Issue | Both
- **Changes made:**
  - <file>: <what changed and why>
- **Rationale:** <why this is the correct fix, what alternative was considered>
- **Commit:** <sha7> (revision commit)
---
```

## Updated File Marker

After updating `spec.md` or `plan.md`, add at the very top of the file (below the title):

```markdown
> Last Revised: YYYY-MM-DD (Revision N - <one-line reason>)
```

## Rules

1. One revision per issue. If spec and plan both need changes for the same issue, use `Type: Both` and list both files.
2. Commit the revision before continuing implementation — the revision commit is separate from task commits.
3. Never silently fix a spec/plan issue without a log entry. The log is the audit trail.
4. For `Implementation Bug` and `Discovered Work`, do NOT create a revision — fix directly or create a follow-up task.

## Example

```markdown
## Revision 1 - 2026-09-02 - Type: Plan

- **Triggered by:** Task 2 depends on Task 3 output but is ordered before Task 3
- **Location:** Phase 1 Task 2: Implement user validation
- **Classification:** Plan Issue
- **Changes made:**
  - plan.md: Swapped Task 2 and Task 3 order; updated Task 2 Consumes to reference Task 3 Produces
- **Rationale:** Execution order must respect data dependency. No spec change needed.
- **Commit:** a1b2c3d
---
```
