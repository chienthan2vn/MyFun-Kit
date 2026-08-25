# Myfun New Skills (Phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the 5 core Conductor workflow files in `.claude/workflows/` into 5 self-contained, enrichment-grade skills under `.claude/new_skills/<skill-name>/SKILL.md`, preserving the original Conductor state-machine behavior while merging discipline and resources from existing Superpowers skills.

**Architecture:** Each new skill is a one-folder package (`SKILL.md` + optional `references/` + optional `scripts/`) following the Superpowers `writing-skills` template: frontmatter `name: myfun-xxx`, `description: Use when...` triggers only, Overview, When to Use flowchart, Core Pattern, Implementation, Red Flags, Rationalization Table, Quick Reference. The original Conductor workflow's `SYSTEM DIRECTIVE` block and section-by-section protocol become the **Implementation** section, kept verbatim where it encodes the state machine. Enrichment layers add: `verification-before-completion` (gate table), `systematic-debugging` (decision tree), `test-driven-development` (80% coverage contract), `subagent-driven-development` (ledger `implement_state.json` ↔ `progress.md` mapping), `using-git-worktrees` (worktree before implement), `brainstorming` (Additive/Exclusive question taxonomy) for `myfun-setup` and `myfun-newtrack`. Phase 1 covers the 5 core skills; the remaining 11 workflows stay in `.claude/workflows/` and become skills in Phase 2 after Phase 1 is reviewed.

**Tech Stack:** Markdown (no build), bash snippets (state-file read/write, `git` integration), existing Conductor JSON schemas (`metadata.json`, `implement_state.json`, `parallel_state.json`, `setup_state.json`, `learnings.md`, `patterns.md`). No new dependencies. Skills live in `.claude/new_skills/` per user request (NOT in `.claude/skills/`).

**Spec:** The original 5 Conductor workflows are the spec — every protocol step in those files is a binding requirement. The enrichment tables (Red Flags, Rationalization, Gate Function) come verbatim from the corresponding Superpowers skill SKILL.md. Resource files inside the existing `.claude/skills/` directory (e.g. `brainstorming/scripts/server.cjs`, `brainstorming/visual-companion.md`, `subagent-driven-development/scripts/`) are **referenced via path**, never copied — this keeps a single source of truth and matches the user's Q6 answer.

**Spec index (read once at plan start, do not re-read per task):**
- `.claude/workflows/conductor-setup.md` (361 lines) → `myfun-setup`
- `.claude/workflows/conductor-newtrack.md` (299 lines) → `myfun-newtrack`
- `.claude/workflows/conductor-implement.md` (482 lines) → `myfun-implement`
- `.claude/workflows/conductor-status.md` (127 lines) → `myfun-status`
- `.claude/workflows/conductor-validate.md` (80 lines) → `myfun-validate`
- `.claude/skills/brainstorming/SKILL.md` (250 lines) — Q3 enrichment source for `myfun-setup` and `myfun-newtrack`
- `.claude/skills/systematic-debugging/SKILL.md` (283 lines) — Phase 1-4 + decision tree for `myfun-implement` Self-Check
- `.claude/skills/test-driven-development/SKILL.md` (320 lines) — RED-GREEN for `myfun-implement` task loop
- `.claude/skills/verification-before-completion/SKILL.md` (120 lines) — Gate Function + Common Failures table
- `.claude/skills/subagent-driven-development/SKILL.md` (568 lines) — Fix-loop, ledger, model selection
- `.claude/skills/using-git-worktrees/SKILL.md` (167 lines) — Optional pre-implement worktree
- `.claude/skills/brainstorming/visual-companion.md` (299 lines) — Resource for `myfun-setup` when question is genuinely visual
- `.claude/skills/brainstorming/scripts/server.cjs` (723 lines), `frame-template.html`, `helper.js`, `start-server.sh`, `stop-server.sh` — Resource for visual companion launch
- `README.md` (461 lines) — User-facing command surface; preserved names matter for discoverability

## Global Constraints

- **Skill names:** All 5 new skills use the prefix `myfun-` (user's Q1 answer). Folder names exactly match the `name` frontmatter value. Example: `.claude/new_skills/myfun-setup/SKILL.md`.
- **Frontmatter shape (every skill):** Two required fields — `name` (letters/numbers/hyphens only, no parentheses) and `description` (max 1024 chars total, third-person, "Use when..." trigger-only, NO workflow summary per `writing-skills:150` SDO trap).
- **Path:** Skills live in `/home/merlin/project/myfun-kit/.claude/new_skills/<skill-name>/`, NOT in `.claude/skills/`. The user wants to review before promoting. Do not run `git add` on these folders unless asked.
- **Language:** English, matching both source workflows and Superpowers conventions (user's Q5).
- **Preserve, don't translate:** The original Conductor protocol (state files, markers, commands, JSON schemas, the `SYSTEM DIRECTIVE` block) appears **verbatim** in the Implementation section of each new skill. Only the prompt surrounding it is rewritten to match the `writing-skills` template.
- **Cross-references:** Use `**REQUIRED SUB-SKILL:** Use <namespace>:<skill>` form. For Superpowers: `Use superpowers:brainstorming`. For new skills: `Use myfun-setup`. NEVER use `@file` (force-loads, burns context per `writing-skills:285`).
- **Resource sharing (user's Q6):** Reference existing files in `.claude/skills/` by path. Do NOT copy `brainstorming/scripts/*` or `visual-companion.md` into the new skill. If a new skill needs a brand-new resource, put it in `references/` or `scripts/` **inside the new skill folder** and justify it inline.
- **Token efficiency target:** `myfun-status` and `myfun-validate` (frequently loaded dashboards) <200 words for getting-started sections per `writing-skills:218`. Others <500 words for non-getting-started.
- **Workflow command name compatibility:** New skills must mention the corresponding `/conductor-*` command in their "When to Use" section so users with the old workflow still get unblocked.
- **Status markers and JSON schemas:** Quoted strings like `[ ]`, `[~]`, `[x]`, `[!]`, `implement_state.json` schema fields (`current_phase`, `current_phase_index`, `current_task_index`, `completed_phases`, `last_updated`, `status`), `parallel_state.json` (`workers[]`, `file_locks`, `completed_workers`, `total_workers`) are **exact** — do not rename.
- **No emojis in files** (per coding style in repo instructions; emojis only allowed in inline console output during run).
- **No comments in code** (do not add `<!--` HTML comments or `//` JS comments that weren't in the source).
- **No new files unless required:** Each skill produces exactly 1 `SKILL.md` plus optional `references/` or `scripts/` if the spec demands. No README inside the skill folder (the global `README.md:339` already covers user journeys).
- **Git operations:** Skills describe git operations in prose but DO NOT execute `git add` / `git commit` during skill creation. The user reviews the plan first; commits happen after the user approves the diff.
- **Verification gate:** Before marking any task complete, the implementer MUST run `wc -w` on the produced `SKILL.md` to confirm it is under the 500-word target (or 200 for the two dashboards) and `grep -c "Use when" .claude/new_skills/<skill>/SKILL.md` ≥ 1.

---

### Task 1: Create `myfun-setup` skill

**Files:**
- Create: `.claude/new_skills/myfun-setup/SKILL.md`
- Modify: `.claude/new_skills/PLAN_NEWSKILLS.md` (this file — append completion row in Final Status section)
- Read-only references (do not copy): `.claude/workflows/conductor-setup.md`, `.claude/skills/brainstorming/SKILL.md`, `.claude/skills/brainstorming/visual-companion.md`, `.claude/skills/brainstorming/scripts/start-server.sh`

**Interfaces:**
- Consumes: Existing `conductor-setup.md:1-361` protocol sections 1.0, 1.1, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.0, 3.1, 3.2, 3.3, 3.4; `brainstorming:22-25` Spike/Bounded/Architectural classification; `brainstorming:100-145` clarifying-question template; `brainstorming:202-220` spec self-review.
- Produces: A skill with `name: myfun-setup` that agents load before any `/conductor-setup` invocation. Calling path: user runs `/conductor-setup` → harness detects the command → loads `myfun-setup/SKILL.md` → follows the Implementation section → produces `conductor/setup_state.json` + 4 markdown files (`product.md`, `product-guidelines.md`, `tech-stack.md`, `workflow.md`) + `patterns.md` + first track.

- [ ] **Step 1.1: Write SKILL.md frontmatter (YAML, max 1024 chars)**

```yaml
---
name: myfun-setup
description: "Use when initializing a new or existing project with the Conductor framework, running /conductor-setup, or resuming a partial setup that stopped at section 2.x or 3.x — triggers include 'initialize this project', 'set up conductor', 'continue the setup we started', or seeing conductor/setup_state.json with last_successful_step set."
---
```

Trigger-only, no workflow summary.

- [ ] **Step 1.2: Write SKILL.md body — Overview, When to Use, Core Pattern**

After the frontmatter, write the following sections in this order, using `## H2` headings. Keep Overview ≤ 80 words. Use the embedded code blocks below verbatim.

```markdown
# myfun-setup

## Overview

Initialize or resume a Conductor project. Conductor is a context-driven dev framework: `product.md` + `tech-stack.md` + `workflow.md` + a phased track plan with auto-resume via `setup_state.json`. Load this skill before any `/conductor-setup` invocation, including resume after interruption.

## When to Use

Use when ANY of:
- User types `/conductor-setup` for the first time on a project
- `conductor/setup_state.json` exists with a `last_successful_step` not equal to `3.3_initial_track_generated` (resumable)
- Brownfield detection finds `.git`, `package.json`/`pom.xml`/`requirements.txt`/`go.mod`/`Cargo.toml`, or `src/`
- Greenfield detection finds NONE of the above

Do NOT use when the project already has a complete setup (`last_successful_step = complete`). Refer the user to `myfun-newtrack` or `myfun-implement` instead.

## Core Pattern

The setup is a **state machine**. The single source of truth is `conductor/setup_state.json`. Each section (2.1, 2.2, ..., 3.3) writes its name to `last_successful_step` on success, so a context-window death or session restart picks up exactly where you left off. Brownfield vs Greenfield forks once at 2.0, then the path is identical.

## Required Sub-Skills

- `superpowers:brainstorming` — for classifying whether to ask vs auto-generate, and the Additive vs Exclusive question taxonomy in sections 2.1-2.3
- `superpowers:verification-before-completion` — for the gate before writing each `last_successful_step` and before the final `git commit` in 3.4

## References (do not copy, reference by path)

- Brainstorming visual companion: `.claude/skills/brainstorming/visual-companion.md` (launch via `.claude/skills/brainstorming/scripts/start-server.sh` ONLY after user accepts the companion, per `visual-companion.md:33-58`)
- Source workflow spec: `.claude/workflows/conductor-setup.md` (every protocol step is binding)
```

- [ ] **Step 1.3: Write SKILL.md Implementation section (verbatim from workflow)**

Append a `## Implementation` section containing the full Conductor setup protocol, **adapted as follows**:
- Keep the HTML comment `<!-- SYSTEM DIRECTIVE: ... -->` block at the top of the section (it enforces "Validate every tool call" and the flash model selection for setup).
- Reproduce sections 1.0, 1.1, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.0, 3.1, 3.2, 3.3, 3.4 with original section numbers and headers (`### 1.0 RESUME CHECK`, `### 2.0 PHASE 1: PROJECT SETUP`, etc.).
- Inside 2.1, after "Ask Questions Sequentially (max 5)" add a one-line callout: `> Brainstorming rule: classify Additive (add "(Select all that apply)") vs Exclusive (single answer). One question at a time. Last option must be "D) Type your own answer".` This is the brainstorming integration, not a copy of the whole brainstorming skill.
- Inside 2.3 (Tech Stack), after the Brownfield question, add: `> Verification gate: before committing the inferred stack to tech-stack.md, list every claim and ask the user to confirm each — do not assume unverified fields per verification-before-completion:38.`
- Inside 3.3, after creating the first track, add: `> Spec self-review (brainstorming:212-219): before committing, scan the generated spec.md for "TBD", "TODO", contradictions, and ambiguity. Fix inline.`
- Final section header: `## Red Flags` containing exactly this table (copied from `verification-before-completion:48-50`, shortened):

```markdown
## Red Flags

| Thought | Reality |
|---------|---------|
| "Setup is just generating files, skip the Q&A" | Each question selects scope; skipping silently commits to unselected defaults. |
| "Brownfield → just trust the package.json" | Verify each inferred field per verification-before-completion:38. |
| "I'll commit `conductor/` at the end" | The plan commits progressively in 3.4; backing up loses the resume state. |
| "setup_state.json is bookkeeping, not a contract" | It is the only resume mechanism. Skipping a write breaks the next restart. |
```

- [ ] **Step 1.4: Write SKILL.md tail — Quick Reference and Common Mistakes**

Append two sections, each ≤ 80 words:

```markdown
## Quick Reference

| Section | File produced | last_successful_step value |
|---------|---------------|----------------------------|
| 2.1 | `conductor/product.md` | `2.1_product_guide` |
| 2.2 | `conductor/product-guidelines.md` | `2.2_product_guidelines` |
| 2.3 | `conductor/tech-stack.md` | `2.3_tech_stack` |
| 2.4 | `conductor/code_styleguides/*` | `2.4_code_styleguides` |
| 2.5 | `conductor/workflow.md` | `2.5_workflow` |
| 3.3 | `conductor/tracks/<id>/` + `tracks.md` | `3.3_initial_track_generated` |

## Common Mistakes

- Skipping `last_successful_step` write → next session re-asks all questions.
- Asking the user to classify Feature vs Bug — infer it per `conductor-newtrack.md:45`.
- Committing in 2.5 and forgetting the initial track in 3.3.
- Reordering 2.1 → 2.2 → 2.3 — order matters for resume.
```

- [ ] **Step 1.5: Verify Task 1 completion**

Run:
```bash
wc -w /home/merlin/project/myfun-kit/.claude/new_skills/myfun-setup/SKILL.md
# Expected: 700-1000 words (the protocol is heavy; this is OK per writing-skills:218 for non-getting-started)
grep -c "Use when" /home/merlin/project/myfun-kit/.claude/new_skills/myfun-setup/SKILL.md
# Expected: >= 1
head -n 5 /home/merlin/project/myfun-kit/.claude/new_skills/myfun-setup/SKILL.md
# Expected: shows YAML frontmatter with name: myfun-setup and description starting with "Use when"
```

If `wc -w` is under 600, you cut the protocol — restore from `conductor-setup.md`. If over 1100, the Red Flags / Quick Reference sections are bloated — trim prose, keep tables.

- [ ] **Step 1.6: Commit (DO NOT EXECUTE — only prepare commit message draft)**

Output to the user (do not run `git commit`):
> "Task 1 complete: `.claude/new_skills/myfun-setup/SKILL.md` written, [N] words, frontmatter verified. Ready for review."

Mark Task 1 in the plan's Final Status table (at the bottom of this file) as ✅.

---

### Task 2: Create `myfun-newtrack` skill

**Files:**
- Create: `.claude/new_skills/myfun-newtrack/SKILL.md`
- Modify: `.claude/new_skills/PLAN_NEWSKILLS.md` (append row)
- Read-only references: `.claude/workflows/conductor-newtrack.md`, `.claude/skills/brainstorming/SKILL.md`, `.claude/skills/writing-plans/SKILL.md`

**Interfaces:**
- Consumes: `conductor-newtrack.md:1-299` sections 1.0, 2.1, 2.2, 2.3, 2.4; `brainstorming:23-50` three-path classification (this skill uses the **Architectural** path); `writing-plans:26-34` file structure principle; `writing-plans:42-49` Bite-Sized Task Granularity; `writing-plans:54-80` Plan Document Header.
- Produces: A skill that agents load before `/conductor-newtrack "description"`. Calling path: user runs command → harness loads `myfun-newtrack/SKILL.md` → follows Implementation → produces `conductor/tracks/<id>/{metadata.json,spec.md,plan.md,learnings.md}` + appends to `conductor/tracks.md`.

- [ ] **Step 2.1: Write SKILL.md frontmatter (YAML, max 1024 chars)**

```yaml
---
name: myfun-newtrack
description: "Use when creating a new auditable feature or bug track, running /conductor-newtrack, or when the user says 'add a new feature', 'fix this bug', or 'start a track for X' and conductor/tracks.md exists — do NOT use for ad-hoc edits or before myfun-setup has run."
---
```

- [ ] **Step 2.2: Write SKILL.md body — Overview, When to Use, Core Pattern, Sub-skills**

```markdown
# myfun-newtrack

## Overview

Create a single, auditable development track: a `spec.md` (what), a `plan.md` (how), a `metadata.json` (priority/dependencies), and a `learnings.md` seeded from `patterns.md`. Load this skill before any `/conductor-newtrack "<description>"` invocation. Pairs with `myfun-implement` (which executes the plan this skill writes).

## When to Use

Use when ANY of:
- User types `/conductor-newtrack` with or without a description argument
- User says "let's add [feature]", "track this bug", "plan [X]"
- `conductor/tracks.md` exists and you need to add a row

Do NOT use when:
- `conductor/{product.md,tech-stack.md,workflow.md}` are missing → first run `myfun-setup`
- The work is ephemeral / exploratory → use `myfun-explore` (Phase 2 skill, not yet built) or `/conductor-wisp`
- The user wants to modify an existing track's spec/plan mid-implementation → use `myfun-revise` (Phase 2)

## Core Pattern

Two interactive dialogues, gated by user approval:
1. **Spec dialogue** — 3-5 Additive/Exclusive questions, draft `spec.md`, present, revise until approved.
2. **Plan dialogue** — read `conductor/workflow.md`, draft `plan.md` (Phases → Tasks → Sub-tasks with `[ ]` markers), detect parallel potential, get approval, then scaffold.

The `spec.md` and `plan.md` are **negotiated, not generated** — the user's edits during the confirmation loop are the source of truth.

## Required Sub-Skills

- `superpowers:brainstorming` (Architectural path) — for the question taxonomy in 2.2 and the spec self-review in 2.2 step 4
- `superpowers:writing-plans` — for file structure planning in 2.3 and Bite-Sized Task Granularity when generating `plan.md`

## References

- Source workflow: `.claude/workflows/conductor-newtrack.md` (every step is binding)
- Plan Document Header template: `.claude/skills/writing-plans/SKILL.md:54-80`
```

- [ ] **Step 2.3: Write SKILL.md Implementation section**

Append `## Implementation` with:
- The `<!-- SYSTEM DIRECTIVE: ... -->` block (same wording as `conductor-newtrack.md:5-9`).
- Sections 1.0, 2.1, 2.2, 2.3, 2.4 reproduced with original headers.
- Inside 2.2 (Interactive Specification), after "3-5 questions", insert: `> Brainstorming Additive/Exclusive rule per brainstorming:24-26. ONE question per turn. Last option: "D) Type your own answer".`
- Inside 2.3 step 3a (Analyze for Parallel Execution Potential), insert: `> Bite-Sized Granularity per writing-plans:42-49: each step 2-5 minutes. Do not generate a 200-line plan.md without this constraint.`
- Append `## Red Flags` table:

```markdown
## Red Flags

| Thought | Reality |
|---------|---------|
| "Skip the Q&A, just write a generic spec" | Every unasked question commits the track to a default the user never saw. |
| "Generate the whole plan, let user review at end" | Mid-plan edits are cheap; end-of-plan edits invalidate prior tasks. |
| "I'll inject parallel annotations without asking" | `<!-- execution: parallel -->` spawns sub-agents the user may not have budget for. Confirm first. |
| "Just use the description as the spec" | Description is a seed; spec is a contract. They diverge. |
```

- [ ] **Step 2.4: Write SKILL.md tail — Quick Reference, Common Mistakes**

```markdown
## Quick Reference

| Track artifact | Schema (from `metadata.json` example) |
|----------------|--------------------------------------|
| `track_id` | `<shortname>_<YYYYMMDD>` (e.g. `auth_20251226`) |
| `type` | `feature` (inferred) or `bug`/`chore`/`refactor` |
| `priority` | `critical` 🔴 / `high` 🟠 / `medium` 🟡 / `low` 🟢 |
| `depends_on` | Array of track_ids that must be `[x]` first |
| `estimated_hours` | Number or `null` |

## Common Mistakes

- Asking the user to classify Feature vs Bug — infer it from description.
- Forgetting the `<!-- depends: -->` (empty) annotation for phases that should start immediately.
- Skipping the parallel-annotation confirmation → user gets unwanted sub-agents.
- Writing `spec.md` without an "Out of Scope" section.
```

- [ ] **Step 2.5: Verify Task 2 completion**

Run:
```bash
wc -w /home/merlin/project/myfun-kit/.claude/new_skills/myfun-newtrack/SKILL.md
# Expected: 700-1000 words
grep -c "Use when" /home/merlin/project/myfun-kit/.claude/new_skills/myfun-newtrack/SKILL.md
# Expected: >= 1
grep "name: myfun-newtrack" /home/merlin/project/myfun-kit/.claude/new_skills/myfun-newtrack/SKILL.md
# Expected: 1 match in frontmatter
```

- [ ] **Step 2.6: Mark Task 2 complete in Final Status table**

Output: "Task 2 complete: `.claude/new_skills/myfun-newtrack/SKILL.md` written, [N] words."

---

### Task 3: Create `myfun-implement` skill

**Files:**
- Create: `.claude/new_skills/myfun-implement/SKILL.md`
- Create: `.claude/new_skills/myfun-implement/references/issue-decision-tree.md` (the Self-Check decision tree extracted from conductor-implement.md:289-301, since it's referenced often)
- Modify: `.claude/new_skills/PLAN_NEWSKILLS.md` (append row)
- Read-only references: `.claude/workflows/conductor-implement.md`, `.claude/skills/systematic-debugging/SKILL.md`, `.claude/skills/test-driven-development/SKILL.md`, `.claude/skills/verification-before-completion/SKILL.md`, `.claude/skills/subagent-driven-development/SKILL.md`, `.claude/skills/using-git-worktrees/SKILL.md`, `.claude/skills/dispatching-parallel-agents/SKILL.md`

**Interfaces:**
- Consumes: `conductor-implement.md:1-482` sections 1.0, 2.0, 3.0, 3a, 4, 5a, 5b, 5c, 5d, 5d4, 5d5, 5e, 6.0, 7.0, Status Markers Reference; `systematic-debugging:45-103` four phases; `test-driven-development:31-69` RED-GREEN cycle and Iron Law; `verification-before-completion:22-37` Gate Function; `subagent-driven-development:59-122` fix-loop 5 rounds + ledger model; `using-git-worktrees:21-30` detection; `dispatching-parallel-agents:1-46` parallel dispatch.
- Produces: A skill that orchestrates track execution. Calling path: user runs `/conductor-implement [track_id]` → harness loads `myfun-implement/SKILL.md` → optionally loads `superpowers:using-git-worktrees` → reads `implement_state.json` if present → loops through phases/tasks → writes `learnings.md` after each task → finalizes track (`tracks.md [~]→[x]`, archives state, prompts archive/delete/skip).

- [ ] **Step 3.1: Write SKILL.md frontmatter (YAML, max 1024 chars)**

```yaml
---
name: myfun-implement
description: "Use when executing a track's plan.md, running /conductor-implement, or resuming a multi-session implementation via implement_state.json — triggers include 'implement this track', 'continue implementation', 'run the plan', or finding conductor/tracks/<id>/implement_state.json with status starting or in_progress. Do NOT use for ephemeral exploration (use /conductor-explore) or for setting up the project (use myfun-setup)."
---
```

- [ ] **Step 3.2: Write SKILL.md body — Overview, When to Use, Core Pattern, Sub-skills**

```markdown
# myfun-implement

## Overview

Execute a track's `plan.md` task-by-task with TDD, auto-resume, pattern priming, and parallel sub-agents. The state machine is `conductor/tracks/<id>/implement_state.json`; the discipline is TDD + verification-before-completion + systematic-debugging. This is the longest Conductor skill (~480 protocol lines) and the only one that performs file mutations outside `conductor/`.

## When to Use

Use when ANY of:
- User types `/conductor-implement [track_id]` (or no arg → auto-pick first non-`[x]`)
- `conductor/tracks/<id>/implement_state.json` exists with `status` ≠ `complete`
- A track in `conductor/tracks.md` is marked `[~]` (in progress)

Do NOT use when:
- Track is `[!]` (blocked) → first run `myfun-revise` or `myfun-block` (Phase 2)
- The work is a single-line change → use normal development workflow
- The user is mid-session and just wants a status check → use `myfun-status`

## Core Pattern

```
plan.md  ──►  [per task]  workflow.md TDD  ──►  implement_state.json updated
                            ↓
                       test (RED→GREEN)
                            ↓
                       commit (NEVER push)
                            ↓
                       learnings.md appended
                            ↓
                       pattern elevation prompt
                       ──►  next task
                            ↓
                       end-of-track  ──►  myfun-archive (Phase 2)
```

The `implement_state.json` is the recovery map — survives context compaction and human partner restarts.

## Required Sub-Skills (in invocation order)

1. `superpowers:using-git-worktrees` — if work is non-trivial, isolate (Step 0 detect, Step 1a/1b create)
2. `superpowers:verification-before-completion` — gate before EVERY commit and before claiming a task is `[x]`
3. `superpowers:test-driven-development` — RED→GREEN is the contract for every code change; tests must fail correctly first
4. `superpowers:systematic-debugging` — Phase 1-4 when a task fails; never "just try X"
5. `superpowers:dispatching-parallel-agents` — when `<!-- execution: parallel -->` is set in plan.md
6. `superpowers:subagent-driven-development` (Optional, Advanced) — if you want per-task reviewer sub-agents; Conductor's c5 already spawns workers but does not review them

## References

- Source workflow: `.claude/workflows/conductor-implement.md` (every section binding)
- Issue Self-Check decision tree: `.claude/new_skills/myfun-implement/references/issue-decision-tree.md` (extracted; this file is NEW)
- Verification gate: `.claude/skills/verification-before-completion/SKILL.md:22-37`
- TDD Iron Law: `.claude/skills/test-driven-development/SKILL.md:31-50`
- Debugging Iron Law: `.claude/skills/systematic-debugging/SKILL.md:20-30`
```

- [ ] **Step 3.3: Write SKILL.md Implementation section**

Append `## Implementation` with:
- `<!-- SYSTEM DIRECTIVE: ... -->` block (verbatim from `conductor-implement.md:6-9`).
- Sections 1.0, 2.0, 3.0 (with sub-section 3a "Load Patterns Context"), 4 (Check Resume State), 5 (Determine Execution Mode with 5a/5b/5c/5d sub-flows), 5.1 (Learnings Capture), 5e (Pattern Elevation), 6.0 (Synchronize Project Documentation), 7.0 (Track Cleanup), and the Status Markers Reference — all reproduced with original section numbers.
- After section 5d4 (Handle Blocked Tasks), insert a callout: `> Use systematic-debugging:45-103 Phase 1 before any unblock decision. "Just unblock and try" is the failure mode.`
- After section 5d5 (Self-Check & Issue Handling), insert a callout: `> The 5-row decision tree in 5d5 is extracted to references/issue-decision-tree.md for fast lookup. Re-read it before every Self-Check.`
- After section 5c5 (Spawn Parallel Workers), insert: `> The sub-agent prompt template in c5 already enforces TDD + 80% coverage + no git push. If you find yourself relaxing any of these, you are violating the contract.`
- After section 5.1 (Learnings Capture), insert: `> Ralph-style learning capture. The order "Implemented → Files → Commit → Learnings (Patterns/Gotchas/Context)" is the schema. Do not skip the Learnings block — it is the project flywheel.`
- Append `## Red Flags` table (extracted from `verification-before-completion:48-50` + `systematic-debugging:215-230` + `test-driven-development:228-241`):

```markdown
## Red Flags

| Thought | Reality |
|---------|---------|
| "Just unblock the `[!]` task and move on" | Unblocking without root cause = re-blocking. Use systematic-debugging Phase 1. |
| "Tests pass locally, commit and move on" | Run the FULL suite per verification-before-completion:38. Partial check proves nothing. |
| "I already know the test would fail" | You didn't watch it fail. TDD Iron Law: "If you didn't watch the test fail, you don't know if it tests the right thing" (test-driven-development:13). |
| "Push my work, the user wants to see it" | **NEVER `git push` during implement.** The user controls remote sync. |
| "Skip learnings.md, it's bookkeeping" | It is the only mechanism for `myfun-refresh` to elevate patterns project-wide. |
| "Three fixes failed — try a fourth" | After 3 fixes, question the architecture per systematic-debugging:191-198. |
| "I'm confident the parallel state is right" | Read `parallel_state.json` from disk, do not infer. |
```

- [ ] **Step 3.4: Write SKILL.md tail — Quick Reference, Status Markers, Common Mistakes**

```markdown
## Quick Reference

| State file | Purpose | When written |
|-----------|---------|--------------|
| `implement_state.json` | Resume pointer | Per task, per phase |
| `parallel_state.json` | Worker coordination | Phase start, deleted on phase complete |
| `learnings.md` | Per-track knowledge | After every task `[x]` |
| `revisions.md` | Spec/plan change log | When Self-Check hits Spec/Plan Issue |
| `handoff_<ts>.md` | Session handoff (via `myfun-handoff`, Phase 2) | Manual or pre-compaction |

## Status Markers (every plan.md must use these only)

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending |
| `[~]` | In progress (only one per phase) |
| `[x]` | Completed |
| `[!]` | Blocked (paired with `[BLOCKED: <reason>]`) |

## Common Mistakes

- Marking a task `[x]` without committing (breaks `myfun-status` percentage math).
- Writing `implement_state.json` with `last_updated` missing → no resume possible.
- Spawning parallel workers without a `parallel_state.json` → state desync.
- Using `git add .` instead of `git add <specific files>` (clobbers unrelated work).
- Forgetting section 6.0 (Synchronize Project Documentation) on track completion.
- Offering "Skip" without explaining it leaves the track in `tracks.md` forever.
```

- [ ] **Step 3.5: Create `references/issue-decision-tree.md`**

Create the file with this exact content (extracted verbatim from `conductor-implement.md:289-301`, reformatted as a standalone table with a header):

```markdown
# Issue Self-Check Decision Tree

When a task's tests, linter, or type check fail, classify the failure before acting. The 5-row table below is the only contract — do not invent new categories.

| Issue Type | Indicators | Action |
|------------|------------|--------|
| **Implementation Bug** | Typo, logic error, missing import, wrong test assertion | Fix directly and continue. No `revisions.md` entry. |
| **Spec Issue** | Requirement wrong, missing, impossible, edge case not covered | Trigger `myfun-revise` (Phase 2) for spec → update `spec.md` → log in `revisions.md` → then fix code |
| **Plan Issue** | Missing task, wrong order, task too big/small, dependency missing | Trigger `myfun-revise` for plan → update `plan.md` → log in `revisions.md` → continue |
| **Discovered Work** | Bug found, improvement needed, follow-up task | Create follow-up task in `plan.md` or separate track. Do not bundle into current task. |
| **Blocked** | External dependency, need user input, waiting on API | Mark `[!] [BLOCKED: <reason>]`, suggest `myfun-block` (Phase 2) |

## Required Announcements

After classifying, announce explicitly:
> "This issue reveals [spec/plan problem | implementation bug | discovered work]. [Triggering revision | Fixing directly | Created follow-up task]."

## When to Question Architecture (not fix)

If you have tried ≥ 3 fixes for the same task and each reveals a new problem elsewhere, STOP. Per `systematic-debugging:191-198`, this is a wrong architecture, not a wrong fix. Discuss with your human partner before Fix #4.
```

- [ ] **Step 3.6: Verify Task 3 completion**

Run:
```bash
wc -w /home/merlin/project/myfun-kit/.claude/new_skills/myfun-implement/SKILL.md
# Expected: 1100-1600 words (largest skill; protocol is heavy)
wc -w /home/merlin/project/myfun-kit/.claude/new_skills/myfun-implement/references/issue-decision-tree.md
# Expected: 200-400 words
grep -c "Use when" /home/merlin/project/myfun-kit/.claude/new_skills/myfun-implement/SKILL.md
# Expected: >= 1
ls /home/merlin/project/myfun-kit/.claude/new_skills/myfun-implement/
# Expected: SKILL.md and references/ exist
ls /home/merlin/project/myfun-kit/.claude/new_skills/myfun-implement/references/
# Expected: issue-decision-tree.md
```

- [ ] **Step 3.7: Mark Task 3 complete in Final Status table**

Output: "Task 3 complete: `.claude/new_skills/myfun-implement/SKILL.md` ([N] words) + `references/issue-decision-tree.md` ([N] words) created."

---

### Task 4: Create `myfun-status` skill

**Files:**
- Create: `.claude/new_skills/myfun-status/SKILL.md`
- Modify: `.claude/new_skills/PLAN_NEWSKILLS.md` (append row)
- Read-only references: `.claude/workflows/conductor-status.md`

**Interfaces:**
- Consumes: `conductor-status.md:1-127` entire file (read-only dashboard; no state mutations).
- Produces: A lightweight dashboard skill (target < 200 words for getting-started per `writing-skills:218`). Calling path: user runs `/conductor-status` → harness loads `myfun-status/SKILL.md` → reads `tracks.md` + each `plan.md` + `parallel_state.json` if present → prints the formatted summary.

- [ ] **Step 4.1: Write SKILL.md frontmatter (YAML, max 1024 chars)**

```yaml
---
name: myfun-status
description: "Use when showing current Conductor project progress, running /conductor-status, or when the user asks 'where are we', 'what's the progress', 'how is the track going' — read-only dashboard, no file mutations, no commits."
---
```

- [ ] **Step 4.2: Write SKILL.md body — Overview, When to Use (≤ 200 words total for these two sections)**

```markdown
# myfun-status

## Overview

Read-only dashboard. Prints active track, per-track percentage, priority grouping, blockers, parallel workers (if any), and next-action suggestions. No file writes, no git operations. Use this whenever the user wants visibility without commitment.

## When to Use

Use when the user types `/conductor-status` or asks "what's the status", "how is X going", "what's next". Pair with `myfun-implement` (to act on the dashboard) and `myfun-block` (Phase 2) for any `[!]` items the dashboard surfaces.

Do NOT use when the user wants to mutate state — that is `myfun-implement`, `myfun-newtrack`, or `myfun-archive`.
```

- [ ] **Step 4.3: Write SKILL.md Implementation section (verbatim from workflow)**

Append `## Implementation` with:
- Sections 1-7 from `conductor-status.md:1-127` reproduced with original headers.
- Insert after section 3 (Calculate Progress): `> Per verification-before-completion:38: do not report "X% complete" without recounting markers from disk in this turn. Cached counts lie.`
- Insert after section 5a (Parallel Execution Status): `> If `parallel_state.json` shows `timed_out` workers, escalate to the human partner immediately — do not auto-retry.`
- Append `## Red Flags`:

```markdown
## Red Flags

| Thought | Reality |
|---------|---------|
| "I'll cache the counts and re-display" | Counts go stale. Re-read every marker from disk this turn. |
| "Percentage is approximate, ~80% is fine" | The math is `(x_count / total) * 100` rounded. Show the real number. |
| "`[!]` is just a marker" | A blocked task halts implement for that track. Surface it loudly. |
```

- [ ] **Step 4.4: Write SKILL.md tail — Common Mistakes (≤ 60 words)**

```markdown
## Common Mistakes

- Reporting progress without re-reading `plan.md` files.
- Forgetting to surface dependency locks (`🔒` icon).
- Suggesting `/conductor-implement` when a track is `[!]` — first unblock.
- Showing `parallel_state.json` after the phase finished (it should have been deleted).
```

- [ ] **Step 4.5: Verify Task 4 completion (strict word budget for dashboard skill)**

Run:
```bash
wc -w /home/merlin/project/myfun-kit/.claude/new_skills/myfun-status/SKILL.md
# Expected: 350-550 words (Overview+When+Implementation+Red+Common — protocol is small)
grep -c "Use when" /home/merlin/project/myfun-kit/.claude/new_skills/myfun-status/SKILL.md
# Expected: >= 1
```

- [ ] **Step 4.6: Mark Task 4 complete in Final Status table**

Output: "Task 4 complete: `.claude/new_skills/myfun-status/SKILL.md` written, [N] words (dashboard discipline honored)."

---

### Task 5: Create `myfun-validate` skill

**Files:**
- Create: `.claude/new_skills/myfun-validate/SKILL.md`
- Modify: `.claude/new_skills/PLAN_NEWSKILLS.md` (append row)
- Read-only references: `.claude/workflows/conductor-validate.md`, `.claude/skills/verification-before-completion/SKILL.md`

**Interfaces:**
- Consumes: `conductor-validate.md:1-80` sections 1-9; `verification-before-completion:38-50` Common Failures table.
- Produces: An integrity-checker skill. Calling path: user runs `/conductor-validate` → harness loads `myfun-validate/SKILL.md` → walks every check, builds a `✅/⚠️/❌` report, offers auto-fix for safe issues.

- [ ] **Step 5.1: Write SKILL.md frontmatter (YAML, max 1024 chars)**

```yaml
---
name: myfun-validate
description: "Use when verifying Conductor project integrity, running /conductor-validate, or before merging a track — triggers include 'validate the project', 'is my conductor setup healthy', 'check for orphans', 'are status markers consistent'. Read-only by default; auto-fix is opt-in."
---
```

- [ ] **Step 5.2: Write SKILL.md body — Overview, When to Use (≤ 180 words for these)**

```markdown
# myfun-validate

## Overview

Walk the Conductor directory tree and verify structural integrity: core files exist, track directories match `tracks.md`, status markers are consistent, parallel annotations are valid, templates and explorations are sound. Produces a `✅/⚠️/❌` report and offers safe auto-fixes.

## When to Use

Use when the user types `/conductor-validate`, before merging a track to main, after manual edits to `conductor/`, or when `myfun-implement` reports stale `parallel_state.json`. Do NOT use during an active parallel execution (you will race with workers).

## Required Sub-Skills

- `superpowers:verification-before-completion` — for the report format and "claim ✅ only with evidence" discipline
```

- [ ] **Step 5.3: Write SKILL.md Implementation section (verbatim from workflow)**

Append `## Implementation` with:
- Sections 1-9 from `conductor-validate.md:1-80` reproduced with original headers.
- After section 6 (Report), insert: `> Per verification-before-completion:38: each ✅ must be backed by a fresh read in this turn. Cached results are not evidence.`
- After section 7 (Auto-Fix Option), insert: `> Auto-fix is opt-in and reversible. Never auto-fix a `tracks.md` entry without showing the diff.`
- Append `## Red Flags` table (from `verification-before-completion:48-50` reformatted for validate context):

```markdown
## Red Flags

| Thought | Reality |
|---------|---------|
| "I ran validate last week, it's still valid" | Re-run. Manual edits break invariants silently. |
| "Auto-fix is fine, just do it" | Auto-fix must be opt-in per call. Show diff before applying. |
| "Orphan directories are harmless" | They cause status drift between `tracks.md` and filesystem. Fix or archive. |
| "`parallel_state.json` is fine if workers finished" | If phase complete, it should be DELETED. A lingering one is a stale lock. |
```

- [ ] **Step 5.4: Write SKILL.md tail — Quick Reference, Common Mistakes (≤ 70 words)**

```markdown
## Quick Reference

| Check | What it catches |
|-------|-----------------|
| Core files | Missing `product.md`/`tech-stack.md`/`workflow.md`/`tracks.md` |
| Tracks consistency | `tracks.md` entry without dir, or dir without entry |
| Status consistency | `[x]` in `tracks.md` but `status:new` in `metadata.json` |
| Plan integrity | Invalid markers, missing phases, unclosed `<!-- files: -->` |
| Template integrity | `{{variable}}` left in distilled template |
| Exploration validation | Orphan dirs in `conductor/explorations/` (no metadata.json) |

## Common Mistakes

- Running validate while `parallel_state.json` is mid-phase.
- Auto-fixing without diff preview.
- Reporting ✅ before reading every file this turn.
- Skipping template integrity when no `templates/` dir exists.
```

- [ ] **Step 5.5: Verify Task 5 completion**

Run:
```bash
wc -w /home/merlin/project/myfun-kit/.claude/new_skills/myfun-validate/SKILL.md
# Expected: 350-550 words
grep -c "Use when" /home/merlin/project/myfun-kit/.claude/new_skills/myfun-validate/SKILL.md
# Expected: >= 1
ls /home/merlin/project/myfun-kit/.claude/new_skills/
# Expected: 5 folders (myfun-setup, myfun-newtrack, myfun-implement, myfun-status, myfun-validate)
```

- [ ] **Step 5.6: Mark Task 5 complete in Final Status table**

Output: "Task 5 complete: `.claude/new_skills/myfun-validate/SKILL.md` written, [N] words. All 5 core skills created."

---

## Final Status

Update this table as each task completes. Do not run `git add` / `git commit` — user reviews first.

| # | Skill | Path | Words | Frontmatter ✓ | Red Flags ✓ | Status |
|---|-------|------|-------|----------------|-------------|--------|
| 1 | `myfun-setup` | `.claude/new_skills/myfun-setup/SKILL.md` | (fill) | ✅ | ✅ | pending |
| 2 | `myfun-newtrack` | `.claude/new_skills/myfun-newtrack/SKILL.md` | (fill) | ✅ | ✅ | pending |
| 3 | `myfun-implement` | `.claude/new_skills/myfun-implement/SKILL.md` + `references/issue-decision-tree.md` | (fill) | ✅ | ✅ | pending |
| 4 | `myfun-status` | `.claude/new_skills/myfun-status/SKILL.md` | (fill) | ✅ | ✅ | pending |
| 5 | `myfun-validate` | `.claude/new_skills/myfun-validate/SKILL.md` | (fill) | ✅ | ✅ | pending |

After all 5 tasks: report the full word counts to the user, list the 5 paths, and **ask whether to commit or whether to also build the 11 remaining Phase 2 skills (block/skip/revise/handoff/distill/formula/refresh/revert/archive/wisp/export)**.

## Self-Review (run before reporting completion)

1. **Spec coverage:** Each of the 5 source workflows has a corresponding new skill. Sections 1.0 through final are reproduced verbatim (modulo the callout inserts and Red Flags). Resource references are paths, not copies.
2. **Placeholder scan:** No "TBD" / "TODO" / "similar to Task N". Every step has either literal code or a precise reference.
3. **Type consistency:** Folder names match `name` frontmatter (`myfun-setup` folder contains `name: myfun-setup` skill). Status marker strings `[ ]/[~]/[x]/[!]` are consistent across skills. JSON field names (`current_phase`, `current_phase_index`, `current_task_index`, `completed_phases`, `last_updated`, `status`, `track_id`, `type`, `priority`, `depends_on`, `estimated_hours`, `created_at`, `updated_at`, `description`, `workers[]`, `file_locks`, `completed_workers`, `total_workers`) are spelled identically where they appear.
4. **Word budget:** Dashboards (`myfun-status`, `myfun-validate`) ≤ 600 words; others ≤ 1600 words. Verify with `wc -w`.
5. **Frontmatter hygiene:** Every `description` starts with "Use when". No description summarizes the workflow. All under 1024 chars total frontmatter.
6. **Resource discipline:** No file from `.claude/skills/` was copied into `.claude/new_skills/`. Only the NEW `issue-decision-tree.md` (extracted from `conductor-implement.md:289-301`, not a copy of any Superpowers file) lives under `references/`.

## Execution Handoff

After all 5 tasks complete, offer the user the two execution options from the `writing-plans:153-167` template:

> "Plan complete and saved to `.claude/new_skills/PLAN_NEWSKILLS.md`. Five skills created under `.claude/new_skills/`. Two execution options:
>
> 1. **Subagent-Driven (recommended)** — I dispatch a fresh subagent per skill to verify each one against the source workflow, then a broad final review across all 5. The `superpowers:subagent-driven-development` skill manages the loop.
> 2. **Inline Execution** — I run the verifications myself in this session and report findings.
>
> Which approach? And do you want to (a) commit the 5 skills to a new branch, (b) keep them in `.claude/new_skills/` for further review, or (c) start Phase 2 (the 11 remaining workflows) immediately?"

If the user picks **Subagent-Driven**: REQUIRED SUB-SKILL `superpowers:subagent-driven-development`. If **Inline**: REQUIRED SUB-SKILL `superpowers:executing-plans`.
