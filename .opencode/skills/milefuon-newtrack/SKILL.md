---
name: milefuon-newtrack
description: Use when creating a new feature, bug fix, chore, or refactor track for the Milefuon architecture. Combines interactive discovery, granular TDD implementation planning, and Milefuon artifact packaging into a structured, trackable unit.
---

# Milefuon New Track Skill

Help turn ideas into fully formed specifications, granular TDD implementation plans, and packaged Milefuon track artifacts through natural collaborative dialogue. The ceremony scales with the task; the approval gate never does.

<HARD-GATE>
Do NOT invoke any implementation tool, write production code, scaffold projects, or take execution action until you have presented your intent (Spike: probe plan; Bounded: short design in chat; Architectural: `spec.md` + `plan.md`) to your human partner and received explicit approval. The artifact scales with the path; the approval gate never does.
</HARD-GATE>

**Language Rule:** All prompts, questions, `spec.md`, `plan.md`, `metadata.json`, and `learnings.md` content MUST be written in English. Conversational communication with the human partner (explanations, summaries, confirmations outside artifacts) is in Vietnamese.

**Path convention:** Inside skill → path from skill (`scripts/...`, `references/...`, `templates/...`). Outside skill → path from project root (`./milefuon/...`).

---

## 1.0 SETUP & ENVIRONMENT CHECK

**PROTOCOL: Verify Milefuon environment is properly set up.**

1. **Check Required Files:** Verify existence of:
   - `./milefuon/product.md`
   - `./milefuon/tech-stack.md`
   - `./milefuon/workflow.md`

2. **Handle Missing Files:**
   - If ANY missing: **HALT** immediately.
   - Announce: "Milefuon is not set up. Please run `milefuon-setup` first."
   - Do NOT proceed.

---

## 1.1 THREE PATHS — Classification

**Before your first question, classify the request and say the classification out loud** — e.g. "this looks bounded, so I'll present a short design in chat rather than write a full spec" — so your human partner can override it:

- **Spike** — a feasibility question ("can we...", "is it possible...", "quick and dirty is fine") whose output is an **answer, not code you keep**. Present the question and what you'll try in 2-3 sentences, get a nod, then find out as cheaply as correctness allows. **No `spec.md`, no `plan.md`, no track artifacts. Scratch in chat only.** Report findings as a recommendation; anything built stays labeled throwaway.
- **Bounded** — a well-scoped change to code that **already exists in this repo**: a new flag, a small endpoint, a one-file fix, a config chore. Bounded measures the repo, not your familiarity — if there is no existing flow to change, it is not bounded. Ask 1-2 clarifying questions that matter, present a short design **IN CHAT** (approach, files touched, testing), and STOP. No full plan document (lightweight `spec.md`/`plan.md` for Milefuon tracking only — see 2.3).
- **Architectural** — new projects, new subsystems, changes that restructure how components fit together or alter interfaces others depend on. Follow the full process: questions, approaches, sectioned design, written `spec.md`, then full `plan.md`.

**Ratchet:** When in doubt between two paths, take the heavier one. Hidden complexity discovered mid-task upgrades the path — stop, say so, and step up. Nothing downgrades mid-task.

### 1.1.1 Milefuon Mapping: Small / Medium / Large

| Size | Path | Signal | Spec artifact | Plan artifact | Track artifact |
|------|------|--------|---------------|---------------|----------------|
| **Small** | Bounded | 1 file, 1 module, chore/config, single-location bug | Lightweight `spec.md` (Overview + Acceptance Criteria + Out of Scope, omit detailed NFR/FR) — or 2-3 sentence design saved as `spec.md` | `plan.md` 1 Phase, ≤3 Tasks, TDD 4 steps | ✅ Yes `metadata.json` + `learnings.md` + `tracks.md` entry |
| **Medium** | Bounded-extended | Multi-file within 1 subsystem, well-scoped chore | Lightweight `spec.md` | `plan.md` 1 Phase, ≤3 Tasks | ✅ Yes |
| **Large** | Architectural | New subsystem, restructure, multi-subsystem, interface change | Full `spec.md` (Overview, FR, NFR, AC, Out of Scope) | Full `plan.md` multiple Phases, TDD granular, Interface Contracts | ✅ Yes |
| **Spike** | Spike | Feasibility question "is it possible?" | No file | No file | ❌ No — scratch in chat |

> Bounded (Small/Medium) still creates a track for tracking, but with lighter ceremony. Spike creates no track.

### 1.1.2 Anti-Pattern: "Too Simple To Need Approval"

Every path ends with approval. A todo list, a single-function utility, a config change — the design may be two sentences in chat, but you MUST present it and get approval. "Simple" tasks are where unexamined assumptions cause the most wasted work. What scales is the artifact, never the approval.

### 1.1.3 Red Flags

| Thought | Reality |
|---------|---------|
| "This is too simple to need a design" | Simple means a short design, not no design. Two sentences in chat, then approval. |
| "I'll call it bounded and skip the spec" | Reaching for a label to skip work IS the doubt — take the heavier path. |
| "It's bounded and the design is obvious — I'll start while they read it" | The gate is the approval, not the design's length. Present, then stop until you hear yes. |
| "I understand this kind of app, so it's bounded" | Bounded measures the repo, not your familiarity. A new project has no existing flow — it is architectural. |
| "The spike works, so I'll keep the code" | A spike's output is an answer. Keeping the code is a new request — classify it. |
| "It grew, but I'm almost done — no need to re-classify" | Hidden complexity upgrades the path mid-task. Stop and say so. |
| "They approved the spike, so the follow-up change is approved too" | Each task gets its own classification and its own approval. |

### 1.1.4 Checklist (per-path)

**Spike:**
1. Explore project context — enough to frame the probe
2. Present question + probe plan — 2-3 sentences
3. Get approval — a nod is enough
4. Investigate — as cheaply as correctness allows
5. Report findings — recommendation; label anything built as throwaway (no track)

**Bounded (Small/Medium):**
1. Explore project context — check files, docs, recent commits
2. Ask 1-2 clarifying questions — one at a time, the ones that matter
3. Present short design in chat — approach, files touched, testing/interfaces
4. Get approval — STOP and wait for explicit yes
5. Draft lightweight `spec.md` + `plan.md` (1 Phase), self-review, user review gates
6. Package track (metadata + learnings + tracks.md)

**Architectural (Large):**
1. Explore project context — check files, docs, recent commits
2. Offer visual companion just-in-time (see 2.4.2)
3. Ask 3-5 clarifying questions — one at a time
4. Propose 2-3 approaches with trade-offs + recommendation + YAGNI
5. Present design in sections scaled to complexity, get approval per section
6. Write full `spec.md`, self-review, user review gate
7. Write full `plan.md`, self-review, user review gate
8. Package track

---

## 2.0 TRACK INITIALIZATION WORKFLOW

### 2.1 Track Description, Path Classification & Type Classification

1. **Load Context:** Read `milefuon/` directory files (`product.md`, `tech-stack.md`, `workflow.md`, `patterns.md`) to ground questions in project context and existing codebase patterns.

2. **Get Track Description:**
   - **If `$ARGUMENTS` provided:** Use it as track description.
   - **If empty:** Ask:
     > "Please provide a brief description of the track (feature, bug fix, chore, etc.) you wish to start."
     Wait for response.

3. **Classify Path (Three Paths):** Analyze description + repo context to classify as `Spike` / `Bounded` / `Architectural` per 1.1. **Announce classification out loud** (e.g. "This looks bounded — I'll present a short design in chat. Correct me if you'd prefer architectural.") and allow override. If `Spike`, branch to 2.2; if `Bounded`, branch to 2.3; if `Architectural`, branch to 2.4.

4. **Infer Track Type:** Analyze description to classify as `feature` or `something else` (`bug`, `chore`, `refactor`). Do NOT ask the user to classify manually. This informs questioning tone in all paths.

---

### 2.2 Spike Path — Scratch in Chat (No Track Artifacts)

*Use when Path == Spike. Output is an answer, not a track.*

1. **Explore Project Context:** Enough to frame the probe (files, docs, recent commits).

2. **Present Question + Probe Plan (2-3 sentences):**
   - State the feasibility question.
   - State what you'll try and how cheaply.
   - Example: "Question: can we parse X with current stack? Probe: try library Y in a throwaway script, 10 min, no commits."

3. **Get Approval (Hard-Gate):** STOP and wait for nod. Do NOT investigate until approved.

4. **Investigate:** As cheaply as correctness allows. Any code is throwaway — do NOT create `milefuon/tracks/`.

5. **Report Findings:** Recommendation + trade-offs. Label anything built as throwaway. Offer to classify follow-up work as Bounded/Architectural if user wants to keep it.

6. **No Packaging:** Do NOT create `metadata.json`, `spec.md`, `plan.md`, `learnings.md`, or `tracks.md` entry.

---

### 2.3 Bounded Path — Small / Medium (Lightweight Track)

*Use when Path == Bounded. Creates a lightweight track — still tracked in `milefuon/`.*

1. **Announce:**
   > "I'll guide you through 1-2 questions and present a short design in chat for this bounded track."

2. **Visual Companion (Just-In-Time Offer):**
   - Do NOT offer upfront. The **first time** a question would genuinely be clearer shown than described (real mockup/layout/diagram — not merely a UI topic), offer it **in its own message** (no other content):
     > "This next part might be easier if I show you — I can put together mockups, diagrams, and comparisons in a browser tab as we go. It's still new and can be token-intensive. Want me to? I'll open it for you."
   - Wait for response. If accepted, run `scripts/start-server.sh --project-dir . --open` per [visual-companion.md](visual-companion.md). If declined, continue text-only.
   - **Per-question decision after acceptance:** Use browser only for visual content (mockups, wireframes, architecture diagrams, side-by-side comparisons); use terminal for requirements, conceptual A/B/C, trade-off lists.

3. **Questioning Phase (1-2 questions, Tailored by Track Type):**
   - **CRITICAL:** Ask ONE question at a time. Wait for response before next.
   - **Question Classification:**
      - **Additive:** Open-ended discovery (users, goals, features) — add "(Select all that apply)".
     - **Exclusive Choice:** Singular decision — single choice only.
   - Always include "Type your own answer" as final option.
   - **If FEATURE:** interactions, inputs/outputs, data involved.
   - **If SOMETHING ELSE (Bug/Chore/Refactor):** reproduction steps, scope boundaries, success criteria.

4. **Approaches & Trade-offs (if non-trivial):**
   - Propose 2-3 distinct approaches with trade-offs, lead with recommendation + rationale, apply **Ruthless YAGNI**.

5. **Present Short Design IN CHAT (Hard-Gate):**
   > "Here's the short design for this bounded track: approach, files touched, interfaces, testing. Does this look right?"
   - Cover: approach, files (1-3 files), interfaces, testing.
   - STOP and wait for explicit yes. Presenting and starting in same breath is skipping the gate.

6. **Draft Lightweight Specification (`spec.md`):**
   - Draft `spec.md` following [templates/spec-template.md](templates/spec-template.md) but **lightweight**: Overview, Acceptance Criteria, Out of Scope (omit detailed FR/NFR unless needed).
   - **Spec Self-Review:** inline check for placeholders, contradictions, scope.
   - **User Review Gate:** Present drafted `spec.md` in chat and STOP:
     > "I've drafted the lightweight specification. Please review:"
     > ```markdown
     > [Drafted spec.md content]
     > ```
     > "Does this accurately capture the requirements? Suggest changes or confirm."
     Revise until confirmed.

7. **Draft Lightweight Plan (`plan.md`):**
   - Announce: "Now I will create a lightweight implementation plan (`plan.md`)."
   - Read confirmed `spec.md`, `milefuon/workflow.md`, `milefuon/patterns.md`.
   - Draft `plan.md` following [templates/plan-template.md](templates/plan-template.md): **1 Phase, ≤3 Tasks**, each with Files + Interfaces (`Consumes`/`Produces`), TDD 4 steps (2-5 min/step), no placeholders, no git commands, plus final meta-task:
     ```markdown
     - [ ] Task: User Manual Verification for Phase '<Phase Name>' (Protocol in workflow.md)
     ```
   - **Plan Self-Review:** check spec coverage, placeholders, type consistency.
   - **User Review Gate:** Present `plan.md` and STOP for confirmation.

8. **Proceed to 2.5 Packaging** (creates lightweight track artifacts — still tracked).

---

### 2.4 Architectural Path — Large (Full Track)

*Use when Path == Architectural. Full ceremony, full artifacts.*

#### 2.4.1 Interactive Discovery & Spec Generation (`spec.md`)

1. **Announce:**
   > "I'll now guide you through questions to build a comprehensive `spec.md` for this track."

2. **Visual Companion (Just-In-Time Offer):**
   - Same protocol as 2.3.2: do NOT offer upfront; offer in its own message the first time a question is genuinely visual; per-question browser vs terminal decision.

3. **Questioning Phase (3-5 questions, Tailored by Track Type):**
   - **CRITICAL:** Ask ONE question at a time. Wait for response before next.
   - **Question Classification:** Additive vs Exclusive Choice + "(Select all that apply)" for Additive, single choice for Exclusive. Always include "Type your own answer".
   - Confirm understanding by summarizing before moving on.
   - **If FEATURE (3-5 questions):** clarifying questions, implementation approaches & trade-offs, UI/UX and data.
   - **If SOMETHING ELSE (2-3 questions):** reproduction steps/root cause, scope boundaries, success criteria.
   - **Scope Decomposition:** Before detailed questions, assess if request describes multiple independent subsystems (e.g. "chat + file storage + billing + analytics") — if so, flag immediately and help decompose into sub-projects, then start with the first sub-project. Each sub-project gets its own spec→plan→track cycle.

4. **Approaches & Trade-offs:**
   - For non-trivial choices, propose **2-3 distinct approaches** with trade-offs, lead with recommendation + rationale, apply **Ruthless YAGNI**.

5. **Present Design in Sections:** Scale each section to complexity (few sentences to 200-300 words), ask after each section whether it looks right. Cover architecture, components, data flow, error handling, testing. Design for isolation: each unit has one purpose, well-defined interfaces, independently testable.

6. **Draft Specification Document:**
   - Draft `spec.md` following [templates/spec-template.md](templates/spec-template.md). Include Overview, Functional Requirements, Non-Functional Requirements (if any), Acceptance Criteria, Out of Scope.

7. **Spec Self-Review & Audit:**
   - Inline check: placeholder scan (TBD/TODO), internal consistency, scope, ambiguity.
   - For complex specs, optionally dispatch reviewer via [references/spec-reviewer-prompt.md](references/spec-reviewer-prompt.md).

8. **User Review Gate (Hard-Gate):**
   - Present drafted `spec.md` in chat and STOP:
     > "I've drafted the specification. Please review:"
     > ```markdown
     > [Drafted spec.md content]
     > ```
     > "Does this accurately capture the requirements? Suggest changes or confirm."
   - Revise until explicitly confirmed.

#### 2.4.2 Granular TDD Implementation Plan Generation (`plan.md`)

1. **Announce:**
   > "Now I will create an implementation plan (`plan.md`) based on the specification."

2. **Plan Construction Rules:**
   - Read confirmed `spec.md`, `milefuon/workflow.md`, `milefuon/patterns.md`.
   - Draft `plan.md` following [templates/plan-template.md](templates/plan-template.md).
   - Decompose into logical **Phases**, **Tasks**, and Sub-tasks (2-5 minutes per step).
   - **File Structure:** Before tasks, map which files will be created/modified and responsibility per file (small focused files, follow existing patterns).

3. **Task Structure Standards:**
   - **Interface Contracts:** Each major task MUST define `Consumes` and `Produces`.
   - **No Placeholders:** NEVER write `TODO`, `TBD`, "implement later", "add error handling", or "write tests for above". Provide explicit snippets.
   - **No Git Commands:** Do NOT include `git add`, `git commit`, `git push`, or `git init`.
   - **TDD Step Granularity:** Red-Green-Refactor:
     ```markdown
     - [ ] Step 1: Write failing test
     - [ ] Step 2: Run test to verify it fails
     - [ ] Step 3: Write minimal implementation
     - [ ] Step 4: Run test to verify it passes
     ```

4. **Phase Completion Verification Meta-Task:**
   - For EACH Phase, append final meta-task:
     ```markdown
     - [ ] Task: User Manual Verification for Phase '<Phase Name>' (Protocol in workflow.md)
     ```

5. **Plan Self-Review & Audit:**
   - Check spec coverage, placeholder scan, type consistency. Optionally dispatch reviewer via [references/plan-reviewer-prompt.md](references/plan-reviewer-prompt.md).

6. **User Review Gate (Hard-Gate):**
   - Present `plan.md` in chat and STOP:
     > "I've drafted the implementation plan (`plan.md`). Please review:"
     > ```markdown
     > [Drafted plan.md content]
     > ```
     > "Does this cover all necessary steps based on spec and workflow? Suggest changes or confirm."
   - Revise until explicitly confirmed.

---

### 2.5 Track Artifact Packaging & Index Registration (Bounded & Architectural Only)

*Skip entirely for Spike.*

1. **Check for Duplicate Track Name:**
   - List existing directories in `milefuon/tracks/`.
   - Extract short names from track IDs (`shortname_YYYYMMDD` → `shortname`).
   - If proposed short name matches an existing track:
     - **HALT** creation immediately.
     - Announce: "Track with shortname '<shortname>' already exists."
     - Suggest a different name or resuming the existing track. Do NOT proceed.

2. **Generate Track ID:** Create unique ID format `shortname_YYYYMMDD` (e.g., `auth_20260901`).

3. **Metadata Surveys:**
   - **Priority Survey:** Ask user:
     > "What priority should this track have?"
     > A) 🔴 Critical - Blocking other work
     > B) 🟠 High - Important, do soon
     > C) 🟡 Medium - Normal priority (default)
     > D) 🟢 Low - Nice to have
   - **Dependencies Survey:** Ask:
     > "Does this track depend on any other tracks being completed first?"
     - If yes: List incomplete tracks from `milefuon/tracks.md`, let user select.
     - Store selected track_ids in `depends_on` array (default `[]`).

4. **Create Track Directory:** `milefuon/tracks/<track_id>/`

5. **Write `metadata.json`:**
   - Populate [templates/metadata-template.json](templates/metadata-template.json) with actual values for `track_id`, `type`, `status`, `priority`, `depends_on`, timestamps (`created_at`, `updated_at`), and `description`.

6. **Write Artifact Files:**
   - `milefuon/tracks/<track_id>/spec.md` (lightweight for Bounded, full for Architectural)
   - `milefuon/tracks/<track_id>/plan.md` (1 Phase for Bounded, multi-Phase for Architectural)

7. **Initialize Learnings File (`learnings.md`):**
   - Check `milefuon/patterns.md` for project-wide codebase patterns.
   - **Check Archived Tracks:** Scan `milefuon/archive/` (if it exists) for completed tracks with similar topics.
   - If similar archived tracks exist, ask:
     > "Found similar archived track(s): `<track_ids>`. Would you like to seed learnings from a previous track? (Enter track_id or 'skip')"
   - Write `milefuon/tracks/<track_id>/learnings.md` using [templates/learnings-template.md](templates/learnings-template.md), inheriting patterns from `patterns.md` and selected archived tracks.
   - *Applies to Bounded (Small/Medium) and Architectural (Large) — per user confirmation.*

8. **Update Tracks Index File:**
   - Announce: "Updating the tracks file."
   - Append to `milefuon/tracks.md`:
     ```markdown

     ---

     ## [ ] Track: <Track Description>
     *Link: [./milefuon/tracks/<track_id>/](./milefuon/tracks/<track_id>/)*
     ```

9. **Announce Completion:**
   > "New track '<track_id>' has been created and added to the tracks file (`milefuon/tracks.md`)."
