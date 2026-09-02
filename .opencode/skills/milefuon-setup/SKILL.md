---
name: milefuon-setup
description: "Use when (a) initializing a new project for Milefuon, OR (b) re-running setup after the 3 overview files were lost. Creates the milefuon/ folder (product.md, tech-stack.md, workflow.md, tracks.md, patterns.md) and AGENT.md. Do NOT use for ongoing track creation — that's milefuon-newtrack. Run once per project before milefuon-newtrack."
---

# Milefuon Setup

Scaffold a new project for the Milefuon context-driven workflow. One-time ceremony. Scope: create overview files + AGENT.md. Do NOT create any track — `milefuon-newtrack` handles that with its discovery gate.

<HARD-GATE>
Do NOT proceed past Section 1.0 if any required tool call fails. Do NOT scaffold until you have presented each drafted file to your human partner and received explicit approval at each Section 2.x gate. No file is written without its review gate.
</HARD-GATE>

**Language Rule:** All artifacts (`product.md`, `tech-stack.md`, `workflow.md`, `AGENT.md`, `tracks.md`, `patterns.md`) MUST be written in English. Conversational communication with the human partner (explanations, summaries, review prompts outside artifacts) is in Vietnamese.

**Path convention:** Inside skill → path from skill (`scripts/...`, `references/...`). Outside skill → path from project root (`./milefuon/...`, `./AGENT.md`).

---

## 1.0 RESUME CHECK

**PROTOCOL: Before starting setup, determine the project's state using the state file.**

1. **Read State File:** Check for `./milefuon/setup_state.json`
   - If it does NOT exist, this is a new project. Proceed to Section 1.1.
   - If it exists, read its content. If the file is empty or corrupted JSON, announce error: *"Corrupted setup state file detected at ./milefuon/setup_state.json. Delete the file to restart setup."* → **HALT**.

2. **Resume Based on State:** Let `last_successful_step` be `STEP`:

   | `STEP` | Action |
   |--------|--------|
   | `""` (empty string) | Pre-init done — proceed to **Section 2.0** |
   | `"product"` | Announce "Resuming: product.md complete. Next: tech-stack.md." → **Section 2.2** |
   | `"tech_stack"` | Announce "Resuming: tech-stack.md complete. Next: workflow.md." → **Section 2.3** |
   | `"workflow"` | Announce "Resuming: workflow.md complete. Next: scaffold." → **Section 2.4** |
   | `"complete"` | Announce "Project already initialized. Run `milefuon-newtrack` to create a track. If overview files are missing or corrupted, re-run `milefuon-setup` — it will auto-detect and repair." → **HALT** |
   | (missing file) | Fresh project → **Section 1.1** |
   | any other value | Announce error "Unrecognized setup state: <STEP>. Manual repair required — delete ./milefuon/setup_state.json and re-run milefuon-setup." → **HALT** |

See `references/resume-states.md` for full state machine.

---

## 1.1 PRE-INIT OVERVIEW

Present to your human partner:

> "Welcome to Milefuon. I will guide you through:
> 1. **Project Discovery:** Analyze if this is a new or existing project
> 2. **Context Files:** Define vision, tech stack, and workflow (3 questions)
> 3. **Scaffold:** Create the ./milefuon/ folder and ./AGENT.md
>
> Total: ~3 questions, ~3 minutes. Let's get started!"

---

## 2.0 PROJECT DISCOVERY — Brownfield / Greenfield Detection

Execute `scripts/detect-brownfield.sh`:

**Brownfield Indicators (ANY match = Brownfield):**
- Dependency manifests: `package.json`, `pom.xml`, `requirements.txt`, `go.mod`, `Cargo.toml`, `pubspec.yaml`, `pyproject.toml`, `setup.py`, `Pipfile`, `pnpm-workspace.yaml`, `deno.json`, `bun.lockb`, `yarn.lock`, `CMakeLists.txt`, `Makefile`, `build.gradle`, `Gemfile`, `composer.json`, `mix.exs`
- Source directories: `src/`, `app/`, `lib/`, `packages/`, `apps/`, `services/`, `backend/`, `frontend/`, `client/`, `server/` containing code files

**Execution:**

1. Run `bash scripts/detect-brownfield.sh`
   - Output `BROWNFIELD` or `GREENFIELD` on stdout
   - Inferred stack (if brownfield) on stderr

2. **IF BROWNFIELD:**
   - Announce: "Existing project detected."
   - Ensure `./milefuon/` exists: `mkdir -p ./milefuon`
   - If `./milefuon/setup_state.json` does NOT exist: create `{"last_successful_step": ""}` (enables resume if setup aborts mid-way)
   - Keep inferred stack for Section 2.2 confirmation.

3. **IF GREENFIELD:**
   - Announce: "New project will be initialized."
   - Execute: `mkdir -p ./milefuon`
   - Create `./milefuon/setup_state.json`: `{"last_successful_step": ""}`

Proceed to **Section 2.1**.

---

## 2.1 Generate Product Guide — `product.md` (1 Question)

1. **Announce:** "Now let's create `./milefuon/product.md` — vision, goals, non-goals."

2. **Ask ONE Question (Additive):**

   > "Who are the target users and what is the core purpose of this project? (Select all that apply)"
   > A) End users — consumer-facing application
   > B) Internal team — tooling / admin / operations
   > C) Developers — library / SDK / platform
   > D) Type your own answer
   > E) Autogenerate and review product.md

   - If user selects **E**: stop questions, generate `./milefuon/product.md` from available context (README, inferred brownfield info, or generic defaults).

3. **Draft Document:** Generate `./milefuon/product.md` using ONLY the user's selected answers. Ignore unselected options. Structure:

   ```markdown
   # Product Overview

   ## Vision
   <One paragraph: what this project builds and why>

   ## Goals
   - Goal 1: <...>

   ## Non-Goals
   - Non-goal 1: <...>

   ## Target Users
   - <Persona derived from answer>

   ---
   Last updated: <YYYY-MM-DD>
   ```

4. **User Review Gate:**
   > "I've drafted `./milefuon/product.md`. Please review:"
   > ```markdown
   > [Drafted content]
   > ```
   > A) **Approve** — Proceed
   > B) **Suggest Changes** — Tell me what to modify
   >
   > Please respond with A or B, or describe the changes you'd like. Do not proceed until you receive explicit approval.

   Loop until user responds with **A** (or equivalent explicit approval).

5. **Write File:** Write to `./milefuon/product.md`.

6. **Commit State:** Update `./milefuon/setup_state.json`:
   ```json
   {"last_successful_step": "product"}
   ```

7. **Continue:** Proceed to Section 2.2.

---

## 2.2 Generate Tech Stack — `tech-stack.md` (1 Question)

1. **Announce:** "Now let's define the technology stack — `./milefuon/tech-stack.md`."

2. **Ask ONE Question:**

   **IF BROWNFIELD (inferred stack available):**
   > "I detected the following stack: <inferred stack> (from package.json / source scan). Is this correct?"
   > A) Yes, this is correct
   > B) No, I need to provide the correct tech stack

   - If **A**: use inferred stack.
   - If **B**: ask follow-up with structured template:
     > "Please provide the correct tech stack:"
     > - Languages: <e.g., TypeScript, Python>
     > - Frameworks: <e.g., Next.js, FastAPI>
     > - Databases: <e.g., PostgreSQL, SQLite>
     > - Tools: <e.g., Docker, Vitest>
     >
     > Or type 'skip' to use generic defaults.

   **IF GREENFIELD:**
   > "What is the primary runtime for this project? (Select one)"
   > A) TypeScript / Node.js
   > B) Python
   > C) Go
   > D) Rust
   > E) Type your own answer

3. **Draft Document:** Generate `./milefuon/tech-stack.md` using ONLY the user's confirmed answer. Structure:

   ```markdown
   # Tech Stack

   ## Languages
   - <...>

   ## Frameworks
   - <...>

   ## Databases
   - <...>

   ## Tools & Infrastructure
   - <...>

   ---
   Last updated: <YYYY-MM-DD>
   ```

4. **User Review Gate:** Same as Section 2.1 — present draft, A) Approve / B) Suggest Changes. Instruct: "Please respond with A or B, or describe the changes you'd like." Loop until user responds with **A**.

5. **Write File:** Write to `./milefuon/tech-stack.md`.

6. **Commit State:**
   ```json
   {"last_successful_step": "tech_stack"}
   ```

7. **Continue:** Proceed to Section 2.3.

---

## 2.3 Generate Workflow — `workflow.md` (1 Question, Default-Prioritized)

1. **Announce:** "Now let's create `./milefuon/workflow.md` — implementation methodology."

2. **Copy Default Workflow:** Read `references/default-workflow.md` for default content:
   - Methodology: TDD (Red → Green → Refactor)
   - Test coverage: >=80%
   - Verification: manual verification task appended to each phase
   - Status markers: `[ ]` pending, `[~]` in-progress, `[x]` done, `[!]` blocked

3. **Ask ONE Question:**
   > "Use the default workflow or customize?"
   > Default includes: TDD, >=80% test coverage, manual verification per phase.
   > A) Default (Recommended)
   > B) Customize

4. **If Customize — ask 2 follow-ups sequentially (one at a time, wait for each response):**
   - **Q1:** "Default coverage is >=80%. Change it?"
     - A) No (Keep 80%)
     - B) Yes (Enter new percentage)
   - **Q2:** "Commit after each task or after each phase?"
     - A) After each task (Recommended)
     - B) After each phase

   Task summaries are always written to the commit message (hardcoded).

   Update draft `./milefuon/workflow.md` based on responses.

5. **User Review Gate:** Present drafted `./milefuon/workflow.md`, A) Approve / B) Suggest Changes. Instruct: "Please respond with A or B, or describe the changes you'd like." Loop until user responds with **A**.

6. **Write File:** Write to `./milefuon/workflow.md`.

7. **Commit State:**
   ```json
   {"last_successful_step": "workflow"}
   ```

---

## 2.4 Scaffold — `./milefuon/` Folder

1. **Announce:** "Creating the ./milefuon/ folder structure."

2. **Execute Scaffold Script:** Run `bash scripts/scaffold.sh`
   - Creates `./milefuon/tracks/` and `./milefuon/archive/` (idempotent)
   - Symlinks or copies `./milefuon/templates/` from sibling templates
   - Creates default `./milefuon/tracks.md` if not exists
   - Creates default `./milefuon/patterns.md` if not exists

   **Verify:** Check exit code is 0. If any step fails, HALT and announce failure.

3. **Commit State:**
   ```json
   {"last_successful_step": "complete"}
   ```

4. **Continue:** Proceed to Section 2.5.

---

## 2.5 Generate AGENT.md — Root Operating Protocol

1. **Announce:** "Creating `./AGENT.md` — the operating protocol every agent reads at session start."

2. **Write File:** Read `references/AGENT-template.md` and write to `./AGENT.md` at project root.

3. **Verify:** Confirm `./AGENT.md` exists at project root with `ls -la ./AGENT.md`.

---

## 3.0 FINALIZATION

1. **Summarize:** List all files created:
   > "Setup complete. Files created:"
   > - `./AGENT.md` — operating protocol (read-before-act, per-session overview files only)
   > - `./milefuon/product.md` — vision, goals, non-goals
   > - `./milefuon/tech-stack.md` — languages, frameworks, databases, tools
   > - `./milefuon/workflow.md` — methodology, coverage
   > - `./milefuon/tracks.md` — track index (empty, ready for newtrack)
   > - `./milefuon/patterns.md` — codebase patterns (empty, populated by archive)
   > - `./milefuon/tracks/` — active track directory (empty)
   > - `./milefuon/archive/` — archived track directory (empty)
   > - `./milefuon/templates/` — symlink to milefuon-newtrack templates
   > - `./milefuon/setup_state.json` — resume state (`complete`)

2. **Next Steps:** Announce:
   > "Run `milefuon-newtrack` to create your first track. Every new session, agents will read the 5 overview files listed in ./AGENT.md before any work."

---

## 4.0 RED FLAGS

| Thought | Reality |
|---------|---------|
| "Let me also create the first track while I'm here" | Setup = scaffold only. newtrack handles discovery + track creation with its own gate. |
| "Product guidelines and style guides are needed too" | YAGNI. Add them when a track needs them — not during setup. |
| "I'll skip the user review gate and just write the file" | Every Section 2.x has a User Review Gate. Violation = invalid setup. |
| "The inferred tech stack is obvious, no need to confirm" | Brownfield inference is a guess. Always confirm with the user. |
| "I can skip the read sequence — I know the stack" | AGENT.md exists precisely so you don't guess. Read all 5 files. |

---

## File Ownership

| File | Created by | Updated by |
|------|-----------|------------|
| `./AGENT.md` | `milefuon-setup` | `milefuon-setup` only (re-run) |
| `./milefuon/product.md` | `milefuon-setup` | `milefuon-archive` (scope pivot) |
| `./milefuon/tech-stack.md` | `milefuon-setup` | `milefuon-archive` (stack change) |
| `./milefuon/workflow.md` | `milefuon-setup` | `milefuon-archive` (methodology change) |
| `./milefuon/tracks.md` | `milefuon-setup` (empty) | `milefuon-newtrack` (append), `milefuon-archive` (status) |
| `./milefuon/patterns.md` | `milefuon-setup` (empty) | `milefuon-archive` (pattern elevation, >=2 occurrences) |
| `./milefuon/tracks/<id>/*` | `milefuon-newtrack` | `milefuon-implement` |
| `./milefuon/archive/<id>/*` | `milefuon-archive` | — |
| `./milefuon/setup_state.json` | `milefuon-setup` | `milefuon-setup` only |
