# Conductor Framework — Usage Guide

A context-driven development workflow system for structured, auditable feature development.

---

## 🎯 Quick Start

```bash
# 1. Initialize project (interactive setup)
/conductor-setup

# 2. Create your first track
/conductor-newtrack "Add user authentication"

# 3. Implement the track
/conductor-implement

# 4. Check progress anytime
/conductor-status
```

---

## 📋 Workflow Flow Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONDUCTOR LIFECYCLE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────────┐    ┌──────────────────┐    ┌────────────────────────┐   │
│   │  SETUP       │───▶│  NEW TRACK       │───▶│  IMPLEMENT             │   │
│   │  (conductor- │    │  (conductor-     │    │  (conductor-           │   │
│   │   setup)     │    │   newtrack)      │    │   implement)           │   │
│   └──────────────┘    └──────────────────┘    └───────────┬────────────┘   │
│                                                           │                │
│                      ┌────────────────────────────────────┘                │
│                      ▼                                                     │
│            ┌─────────────────────┐                                         │
│            │  TRACK OPERATIONS   │                                         │
│            ├─────────────────────┤                                         │
│            │ • /conductor-status │  ──▶  View progress                    │
│            │ • /conductor-block  │  ──▶  Mark task blocked                │
│            │ • /conductor-skip   │  ──▶  Skip current task                │
│            │ • /conductor-revise │  ──▶  Update spec/plan mid-stream      │
│            │ • /conductor-handoff│  ──▶  Create session handoff doc       │
│            └───────────┬─────────┘                                         │
│                        │                                                    │
│            ┌───────────┴───────────┐                                       │
│            │  TRACK COMPLETION     │                                       │
│            ├───────────────────────┤                                       │
│            │ • /conductor-validate │  ──▶  Verify integrity               │
│            │ • /conductor-distill  │  ──▶  Extract template from track    │
│            │ • /conductor-archive  │  ──▶  Archive completed track        │
│            │ • /conductor-export   │  ──▶  Generate project summary       │
│            └───────────┬───────────┘                                       │
│                        │                                                    │
│            ┌───────────┴───────────┐                                       │
│            │  MAINTENANCE          │                                       │
│            ├───────────────────────┤                                       │
│            │ • /conductor-refresh  │  ──▶  Sync docs with codebase        │
│            │ • /conductor-formula  │  ──▶  Manage templates               │
│            │ • /conductor-revert   │  ──▶  Git-aware revert               │
│            └───────────────────────┘                                       │
│                        │                                                    │
│                        ▼                                                    │
│   ┌──────────────────────────────────────────────────────────────────┐    │
│   │  EXPLORATIONS (ephemeral, no git history)                         │    │
│   │  /conductor-explore <template>  ──▶  Quick ad-hoc investigation  │    │
│   └──────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Core Workflows

### 1. `/conductor-setup` — Initialize Project

**Purpose:** Bootstrap Conductor in a new or existing project.

**What it does:**
- Detects Brownfield (existing code) vs Greenfield (new project)
- Interactive Q&A to create:
  - `conductor/product.md` — Product vision & requirements
  - `conductor/product-guidelines.md` — Brand voice, style
  - `conductor/tech-stack.md` — Languages, frameworks, tools
  - `conductor/workflow.md` — Implementation methodology
  - `conductor/code_styleguides/` — Copied style guides
- Generates initial track with `spec.md`, `plan.md`, `learnings.md`
- Creates `conductor/patterns.md` for cross-track knowledge capture

**Resume capability:** Tracks progress in `conductor/setup_state.json` — can resume after interruption.

---

### 2. `/conductor-newtrack "description"` — Create Feature Track

**Purpose:** Create a new auditable development track with specification and plan.

**Interactive flow:**
1. **Spec generation** — 3-5 questions (Additive vs Exclusive Choice)
2. **Plan generation** — Hierarchical phases/tasks with `[ ]` markers
3. **Parallel analysis** — Auto-detects parallelizable tasks/phases
4. **Track artifacts** — Creates:
   - `conductor/tracks/<track_id>/metadata.json`
   - `conductor/tracks/<track_id>/spec.md`
   - `conductor/tracks/<track_id>/plan.md`
   - `conductor/tracks/<track_id>/learnings.md` (seeded from project patterns)
5. **Updates** `conductor/tracks.md` index

**Key features:**
- Inherits patterns from `conductor/patterns.md`
- Optionally seeds from archived similar tracks
- Injects phase verification tasks from `workflow.md`
- Optional parallel execution annotations

---

### 3. `/conductor-implement [track_id]` — Execute Track

**Purpose:** Run the implementation plan with full state management.

**Execution modes:**

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Sequential** | Default or `<!-- execution: sequential -->` | One task at a time, follows `workflow.md` TDD cycle |
| **Parallel Tasks** | `<!-- execution: parallel -->` on phase | Spawns sub-agents per task with file ownership |
| **Parallel Phases** | `<!-- depends: -->` (empty) or phase list | Multiple phases run simultaneously |

**State management:**
- `implement_state.json` — Resume point (phase, task, status)
- `parallel_state.json` — Worker tracking for parallel execution
- Auto-commits after each task (never pushes)
- Learnings captured after each completed task

**Issue handling decision tree:**
| Issue Type | Action |
|------------|--------|
| Implementation Bug | Fix directly, continue |
| Spec Issue | Trigger `/conductor-revise` for spec |
| Plan Issue | Trigger `/conductor-revise` for plan |
| Discovered Work | Add follow-up task |
| Blocked | Mark `[!]`, suggest `/conductor-block` |

**Completion:**
- Updates `tracks.md` status to `[x]`
- Syncs project docs (`product.md`, `tech-stack.md`)
- Offers archive/delete/keep choice
- Elevates patterns to `patterns.md`

---

### 4. `/conductor-status` — View Progress

**Shows:**
- Active track with completion %
- All tracks grouped by priority (🔴 Critical → 🟢 Low)
- Blocked tracks with dependency chains
- Blockers (tasks marked `[!]`)
- Current task & next action
- Recent completions with commit SHAs
- Parallel execution worker status (if applicable)

---

## 🛠 Track Operations (Mid-Stream)

### `/conductor-block [task]` — Mark Blocked
- Finds current in-progress task or lets you select
- Changes `[~]` → `[!] [BLOCKED: reason]`
- Updates `plan.md`

### `/conductor-skip [task]` — Skip Current Task
- Options: "Complete later" → resets to `[ ]`, "No longer needed" → `[x] (SKIPPED)`
- Marks next pending task as `[~]`
- Updates `implement_state.json`

### `/conductor-revise` — Update Spec/Plan Mid-Stream
- Handles parallel execution conflicts
- Revision types: Spec / Plan / Both
- Creates entry in `revisions.md` with trigger, changes, rationale
- Adds "Last Revised" marker to updated files
- Logs revision as learning (gotcha + pattern for future)

### `/conductor-handoff` — Create Session Handoff
- Captures progress %, current phase/task, completed/pending
- Extracts recent learnings from `learnings.md`
- Records key decisions, code changes, unresolved issues
- Creates `handoff_<timestamp>.md` with resume instructions
- Updates `implement_state.json` with section tracking
- Git commits handoff document

---

## ✅ Track Completion

### `/conductor-validate` — Verify Integrity
Checks:
- Core files exist
- Track directories match `tracks.md`
- Metadata completeness
- Status marker consistency (`[ ]`, `[~]`, `[x]`, `[!]`)
- Plan structure & parallel annotations
- Template integrity in `conductor/templates/`
- Exploration workspace in `conductor/explorations/`
- Offers auto-fix for common issues

### `/conductor-distill <track_id>` — Extract Template
- Requires completed track (`[x]`)
- Analyzes `spec.md` + `plan.md` for parameterizable values
- Proposes variables (e.g., `{{module_name}}`, `{{auth_protocol}}`)
- Creates template in `conductor/templates/<name>/`:
  - `spec.template.md`
  - `plan.template.md`
  - `metadata.json` (with variable descriptions, defaults, required flags)
- Offers to archive source track

### `/conductor-archive [track_id]` — Archive Completed Tracks
- Lists all `[x]` tracks
- Extracts learnings before archiving (elevates to `patterns.md`)
- Moves `conductor/tracks/<id>/` → `conductor/archive/<id>/`
- Removes from `tracks.md`

### `/conductor-export` — Generate Project Summary
Creates markdown export with:
- Product overview
- Tech stack summary
- All tracks (completed, in-progress, pending)
- Statistics
- Options: Save to `conductor/export_YYYYMMDD.md`, overwrite `README.md`, or print

---

## 🔄 Maintenance

### `/conductor-refresh [scope]` — Sync Docs with Codebase
**Scopes:** `all` (default), `tech`, `product`, `workflow`, `track <id>`

**Analyzes drift:**
- Tech: package.json, requirements.txt for dependency changes
- Product: Completed tracks not reflected in `product.md`
- Workflow: CI/CD, tooling changes

**Pattern Flywheel (8a):**
- Scans all track `learnings.md` (active + archive)
- Finds patterns mentioned 2+ times across tracks
- Presents consolidation report
- Updates `conductor/patterns.md` with attribution

### `/conductor-formula [list|show <name>]` — Manage Templates
- `list` — Shows all templates in `conductor/templates/` with variables
- `show <name>` — Displays template structure, variables, usage examples
- Templates created via `/conductor-distill`
- Used by `/conductor-newtrack` (persistent) or `/conductor-explore` (ephemeral)

### `/conductor-revert [track|phase|task]` — Git-Aware Revert
- Guided selection menu (in-progress first, then recent completed)
- Finds ALL associated Git commits (implementation + plan updates)
- Handles "ghost commits" from rewritten history
- Presents final plan with commit list before execution
- Runs `git revert` in reverse order
- Resets plan status markers (`[x]` → `[ ]`)
- Conflicts: HALTs with clear resolution instructions

---

## ⚡ Explorations (Ephemeral)

### `/conductor-explore [template] [--var key=value]` — Quick Investigation

**Characteristics:**
- Lives in `conductor/explorations/<timestamp>/` (gitignored)
- No audit trail, no git sync
- Perfect for: exploration, debugging, quick fixes, patrol cycles

**Commands:**
| Command | Purpose |
|---------|---------|
| `/conductor-explore <template>` | Create from template |
| `/conductor-explore "Explore X"` | Create ad-hoc |
| `/conductor-explore list` | List active explorations |
| `/conductor-explore save <id>` | Create digest of findings |
| `/conductor-explore promote <id>` | Convert to persistent track |
| `/conductor-explore burn <id>` | Delete without trace |

---

## 📁 Directory Structure

```
project/
├── conductor/
│   ├── product.md              # Product vision & requirements
│   ├── product-guidelines.md   # Brand voice, communication style
│   ├── tech-stack.md           # Languages, frameworks, tools
│   ├── workflow.md             # Implementation methodology
│   ├── tracks.md               # Track index (status, links)
│   ├── patterns.md             # Cross-track reusable patterns
│   ├── code_styleguides/       # Copied style guides
│   ├── templates/              # Reusable track templates
│   │   └── <template_name>/
│   │       ├── metadata.json
│   │       ├── spec.template.md
│   │       └── plan.template.md
│   ├── tracks/                 # Active tracks
│   │   └── <track_id>/
│   │       ├── metadata.json
│   │       ├── spec.md
│   │       ├── plan.md
│   │       ├── learnings.md
│   │       ├── revisions.md
│   │       ├── implement_state.json
│   │       ├── parallel_state.json (if parallel)
│   │       └── handoff_*.md
│   ├── archive/                # Archived tracks (git tracked)
│   │   └── <track_id>/
│   └── explorations/           # Ephemeral (gitignored!)
│       └── explore_YYYYMMDD_HHMMSS/
├── .gitignore                  # Includes conductor/explorations/
└── src/                        # Your project code
```

---

## 🏷 Status Markers

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending |
| `[~]` | In Progress |
| `[x]` | Completed |
| `[!]` | Blocked |

---

## 🎯 Typical User Journeys

### New Project (Greenfield)
```bash
/conductor-setup                    # Full interactive setup
/conductor-newtrack "User auth"     # Create track
/conductor-implement                # Build it
/conductor-status                   # Check progress
/conductor-validate                 # Verify before done
/conductor-archive                  # Clean up
```

### Existing Project (Brownfield)
```bash
/conductor-setup                    # Scans existing code, infers stack
/conductor-newtrack "Add payments"  # New feature on existing base
/conductor-implement
/conductor-refresh                  # Sync docs after major changes
```

### Long-Running Track (Multi-Session)
```bash
/conductor-implement                # Start work
... work work work ...
/conductor-handoff                  # Save context before stopping
# Next session:
/conductor-implement                # Resumes from implement_state.json
```

### Debugging / Spike
```bash
/conductor-explore "Debug memory leak"  # Ephemeral, no git history
... investigate ...
/conductor-explore save <id>            # Save findings
/conductor-explore promote <id>         # Convert to real track if needed
```

### Template Reuse
```bash
/conductor-formula list               # See available templates
/conductor-formula show auth          # Inspect template
/conductor-newtrack                   # Uses template interactively
# OR
/conductor-explore auth --var module=payments  # Quick exploration
```

### Recovery
```bash
/conductor-status                     # See where things stand
/conductor-revert task                # Undo a mistake (git-aware)
/conductor-revise                     # Fix spec/plan if wrong
/conductor-validate                   # Check integrity
```

---

## 💡 Key Concepts

### Ralph-Style Knowledge Capture
- **`learnings.md`** per track — Patterns, gotchas, context discovered during implementation
- **`patterns.md`** project-wide — Elevated patterns from multiple tracks
- **Auto-seeding** — New tracks inherit project patterns + optionally from similar archived tracks
- **Pattern elevation prompts** — At phase/track completion, archive, or refresh

### Parallel Execution
- **Task-level:** Within a phase, independent tasks run as sub-agents with file ownership
- **Phase-level:** Independent phases run simultaneously
- **Annotations in `plan.md`:**
  ```markdown
  ## Phase 1: Core Setup
  <!-- execution: parallel -->
  
  - [ ] Task 1: Create auth module
    <!-- files: src/auth/index.ts -->
  - [ ] Task 2: Create config module
    <!-- files: src/config/index.ts -->
  ```

### Git Integration
- All Conductor operations commit locally (`git add conductor/ && git commit`)
- **Never runs `git push`** — user controls remote sync
- Revert uses `git revert` to preserve history
- Handoffs, revisions, archives all create descriptive commits

### Resume Capability
Every long-running workflow maintains state:
- `setup_state.json` — Setup progress
- `implement_state.json` — Track implementation position
- `parallel_state.json` — Worker coordination
- `refresh_state.json` — Last refresh timestamp

---

## 🔗 Command Reference

| Command | Arguments | Purpose |
|---------|-----------|---------|
| `/conductor-setup` | — | Initialize project |
| `/conductor-newtrack` | `[description]` | Create new track |
| `/conductor-implement` | `[track_id]` | Execute track |
| `/conductor-status` | — | Show progress |
| `/conductor-block` | `[task]` | Mark task blocked |
| `/conductor-skip` | `[task]` | Skip current task |
| `/conductor-revise` | — | Update spec/plan |
| `/conductor-handoff` | — | Create session handoff |
| `/conductor-validate` | — | Verify integrity |
| `/conductor-distill` | `<track_id> [--as <name>]` | Extract template |
| `/conductor-archive` | `[track_id]` | Archive completed tracks |
| `/conductor-export` | — | Generate summary |
| `/conductor-refresh` | `[scope]` | Sync docs with code |
| `/conductor-formula` | `[list\|show <name>]` | Manage templates |
| `/conductor-revert` | `[track\|phase\|task]` | Git-aware revert |
| `/conductor-explore` | `[template\|"desc"] [--var k=v]` | Ephemeral exploration |

---

## 📖 Further Reading

- **`conductor/workflow.md`** — Your implementation methodology (TDD, commit conventions, etc.)
- **`conductor/patterns.md`** — Accumulated codebase knowledge
- **Track `learnings.md`** — Per-track discoveries
- **`conductor/templates/`** — Your reusable workflow patterns