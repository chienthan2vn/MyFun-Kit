---
name: milefuon-implement
description: Use when executing a Milefuon track's plan.md task-by-task with TDD, resume support, and learnings capture. Triggers on "implement track / continue track / resume implementation".
---

# Milefuon Implement

Execute a Milefuon track's `plan.md` task-by-task following the TDD workflow. Sequential by default; parallel via subagents when `<!-- execution: parallel -->` is present and capability available.

<HARD-GATE>
Do NOT deviate from plan.md without logging a revision. The plan is the binding argument for the spec — if reality differs from the plan, fix the plan first (revision log), then continue. Never skip the resume check or dependency check.
</HARD-GATE>

**Language Rule:** All prompts, code artifacts, `revisions.md`, and `learnings.md` content MUST be written in English. Conversational communication with the human partner (explanations, summaries, confirmations outside artifacts) is in Vietnamese.

**Path convention:** Inside skill → path from skill (`references/...`). Outside skill → path from project root (`./milefuon/...`).

---

## 1.0 SETUP CHECK

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

## 2.0 TRACK SELECTION

**PROTOCOL: Identify and select the track to be implemented. One track per run.**

1. **Check for User Input:** Check if track ID/name provided as `$ARGUMENTS`.

2. **Parse Tracks File:** Read `./milefuon/tracks.md`
   - Split by `---` separator to identify track sections
   - Extract per section: status (`[ ]`, `[~]`, `[x]`, `[!]`), description, folder link `./milefuon/tracks/<track_id>/`
   - **CRITICAL:** If no track sections found: announce "The tracks file is empty or malformed." → **HALT**

3. **Select Track:**

   **If track name/ID provided:**
   - Exact, case-insensitive match against descriptions and track_ids
   - If unique match: Confirm "I found track '<description>' (<track_id>). Is this correct?"
   - If no match or ambiguous: Inform user, suggest next available incomplete track

   **If no track name provided:**
   - Find first track NOT marked `[x]`
   - Announce: "No track name provided. Selecting next incomplete track: '<description>' (<track_id>)"
   - If all complete: "No incomplete tracks found. All tasks completed!" → **HALT**

4. **Check Dependencies:**
   - Read `./milefuon/tracks/<track_id>/metadata.json`
   - If `depends_on` array is not empty:
     - For each dependency, check status in `./milefuon/tracks.md`
     - If ANY not `[x]` (completed):
       > "⚠️ This track has incomplete dependencies:"
       > [List blocking tracks with their status]
       > "Do you want to proceed anyway?"
       > A) Yes - Proceed despite incomplete dependencies
       > B) No - Implement dependencies first
     - If B: Suggest `milefuon-implement <first_dependency>` and halt current track

5. **Handle No Selection:** If no track selected after steps above, inform user and await instructions.

6. **Update Status to In Progress:**
   - In `./milefuon/tracks.md`, change `## [ ] Track:` to `## [~] Track:` for the selected track
   - This marks the track as actively being implemented

---

## 3.0 LOAD TRACK CONTEXT

**PROTOCOL: Load all context needed for implementation.**

1. **Announce Action:** State which track you are beginning to implement: "Implementing track '<track_id>: <description>'"

2. **Load Track Context:**
   - Identify track folder from tracks file link → get `<track_id>`
   - Read (using paths from project root):
     - `./milefuon/tracks/<track_id>/plan.md`
     - `./milefuon/tracks/<track_id>/spec.md`
     - `./milefuon/workflow.md`
   - **Error Handling:** If any read fails, STOP and inform user with the specific file that could not be read

3. **Load Patterns Context (Ralph-style knowledge priming):**
   - **Read Project Patterns:** If `./milefuon/patterns.md` exists:
     - Read and announce: "📚 **Codebase Patterns:** Found X patterns from previous tracks"
     - These patterns inform implementation decisions
   - **Read Track Learnings:** If `./milefuon/tracks/<track_id>/learnings.md` exists:
     - Read to understand prior work on this track
     - Display: "📝 **Track Learnings:** Resuming with context from previous sessions"
   - **Read Previous Track Learnings (optional):** For similar tracks in archive:
     - Scan `./milefuon/archive/` for tracks with similar names/descriptions
     - Read their `learnings.md` for relevant patterns

---

## 3.1 RESUME STATE

**PROTOCOL: Support resuming interrupted implementations.**

1. **Check for:** `./milefuon/tracks/<track_id>/implement_state.json`

2. **If exists:**
   - Read state file (see `references/resume-states.md` for schema)
   - If file is empty or corrupted JSON: announce "Corrupted implement state file detected at ./milefuon/tracks/<track_id>/implement_state.json. Delete the file to restart implementation." → **HALT**
   - If `status == "completed"`: state should have been deleted already. Announce "Track already marked completed but state not cleaned — cleaning up." → Delete `implement_state.json` (and `parallel_state.json` if present) → Proceed to §5.0 Finalize
   - If `current_phase_index` or `current_task_index` is out of bounds for current `plan.md` (plan was revised after state was saved): announce "State references non-existent phase/task — plan.md may have been revised. Manual recovery required." → **HALT**
   - Check for parallel interruption: If `./milefuon/tracks/<track_id>/parallel_state.json` exists:
     - Read it per `references/resume-states.md` § Parallel State File
     - If any worker is still `in_progress` and updated within 60 minutes: resume monitoring per §4.3 c6
     - If no active workers or all `completed`/`failed`/`timed_out`: delete `parallel_state.json` and re-execute that phase
   - Announce: "Resuming implementation from [current_phase] (Phase [current_phase_index + 1]) - Task [current_task_index + 1]"
   - Skip to indicated phase and task within that phase

3. **If not exists:**
   - But check for stale `parallel_state.json` without `implement_state.json`: if found, delete it (orphaned from previous crash)
   - Create initial state:
     ```json
     {
       "current_phase": "",
       "current_phase_index": 0,
       "current_task_index": 0,
       "completed_phases": [],
       "last_updated": "<ISO8601>",
       "status": "starting"
     }
     ```

See `references/resume-states.md` for full state machine and recovery protocol.

---

## 4.0 EXECUTION LOOP

### 4.1 Phase Graph — Parse Phase Dependencies

For each phase in `plan.md`, check for `<!-- depends: -->` annotation **at the phase heading level** (phase dependency). Note: `<!-- depends: -->` at a task line is a task dependency (§4.3 c1) — disambiguate by heading vs task scope.

- **If NO annotation:** Phase depends on previous phase (sequential, default)
- **If `<!-- depends: -->` (empty):** Phase has no dependencies (can start immediately)
- **If `<!-- depends: phase1, phase2 -->`:** Phase waits for listed phases only
- Build a phase dependency graph to determine which phases can run in parallel

**Validation after building graph:**
- If `depends:` references a non-existent phase name: announce "Unknown phase dependency '<name>' in plan.md" → **HALT** or trigger Plan Issue revision
- Detect circular dependencies: if a cycle is found → announce "Circular dependency detected: <cycle>" → **HALT**
- Normalize file paths for comparison: trim whitespace, strip leading `./`, resolve relative to project root (e.g., `src/foo.ts` == `./src/foo.ts`)

**Identify Ready Phases:**
- Find phases with no unmet dependencies (all dependent phases completed)
- If multiple phases are ready simultaneously, they can run in parallel (if subagents available)
- Process ready phases — may be single or multiple

### 4.2 Task Execution Mode

For each ready phase, check for `<!-- execution: parallel -->` annotation:

- If found **and** subagents available: Go to §4.3 Parallel Task Execution
- If found but no subagents: Warn "Parallel requested but no subagent capability — executing sequentially" → Go to §4.4
- If not found or `<!-- execution: sequential -->`: Go to §4.4 Sequential Task Execution

### 4.3 PARALLEL TASK EXECUTION FLOW

Use when phase is annotated `<!-- execution: parallel -->` and subagents are available.

**c1. Parse Parallel Task Metadata:**
- For each task in the phase, extract:
  - `<!-- files: path1, path2 -->` — Files this task owns exclusively
  - `<!-- depends: task1, task2 -->` — Dependencies on other tasks in phase
  - `<!-- parallel-group: groupName -->` — Optional grouping
- **Validation:** If any task in a parallel phase lacks `<!-- files: -->` annotation: warn "Task '<name>' in parallel phase missing files: annotation → treating as sequential or HALT". If `depends:` references a non-existent task in the same phase: announce "Unknown task dependency '<name>'" → **HALT** or trigger revision.

**c2. Build Dependency Graph:**
- Identify tasks with no `depends:` annotation (can start immediately)
- Identify dependent tasks (must wait for dependencies to complete)
- Create execution order respecting dependencies

**c3. Detect File Conflicts:**
- Check if any two tasks claim the same file in `files:` annotation
- If conflicts detected:
  > "⚠️ File conflict detected: [files] claimed by multiple tasks"
  > "A) Make conflicting tasks sequential (recommended)"
  > "B) Continue anyway - I'll handle manually"
  > "C) Stop and revise plan"
  - If A: Remove parallel annotation from conflicting tasks, execute sequentially
  - If B: Proceed with warning
  - If C: HALT

**c4. Initialize Parallel State:**
- Create `./milefuon/tracks/<track_id>/parallel_state.json`:
  ```json
  {
    "phase": "<phase_name>",
    "execution_mode": "parallel",
    "started_at": "<ISO8601>",
    "workers": [],
    "file_locks": {},
    "completed_workers": 0,
    "total_workers": <count>
  }
  ```

**c5. Spawn Parallel Workers:**
- For each task with no unmet dependencies, spawn a subagent:
  ```
  Task({
    description: "Implement: <task_name>",
    prompt: "
      You are a Milefuon subagent implementing a single task.

      ## Context
      - Track: <track_id>
      - Phase: <phase_name>
      - Task: <task_description>
      - Worker ID: <worker_id>

      ## Files Owned (ONLY modify these files)
      <files_list>

      ## Instructions
      1. Follow workflow.md TDD process (Red → Green → Refactor)
      2. ONLY create/modify files in your owned list above
      3. Run tests and ensure coverage per workflow.md (>=80% default)
      4. Commit with message: <type>(<scope>): <description>
      5. NEVER run git push - all commits stay local
      6. After commit, update parallel_state.json:
         - Find your worker entry by worker_id
         - Set status to 'completed'
         - Set commit_sha to your commit hash
         - Set completed_at to current timestamp

      ## Spec Context
      <relevant_spec_excerpt>

      ## Success Criteria
      - All tests pass
      - Code coverage meets workflow.md target
      - Only owned files modified
      - Commit created with proper message
      - parallel_state.json updated
    "
  })
  ```
- Record each spawned worker in `parallel_state.json`:
  ```json
  {
    "worker_id": "worker_<task_index>_<sanitized_name>",
    "task": "<task_description>",
    "task_index": <index>,
    "files": ["<file1>", "<file2>"],
    "depends_on": ["<task_id>"],
    "status": "in_progress",
    "started_at": "<ISO8601>"
  }
  ```
- Update `file_locks` with each worker's file ownership

**c6. Monitor Worker Completion:**
- Periodically read `parallel_state.json` (every 30 seconds)
- When a worker completes (status = "completed"):
  - Check if any dependent tasks can now start
  - Spawn newly unblocked workers
  - Increment `completed_workers` count
- Handle worker failures:
  - If worker status = "failed": Log error, ask user for resolution
  - If worker hasn't updated in 60 minutes: Mark as "timed_out"

**c7. Aggregate Results:**
- Wait until all workers complete
- Update `plan.md`:
  - Mark all parallel tasks as `[x]` complete
  - Append commit SHAs from each worker
- Delete `parallel_state.json`
- Check phase graph: are there other ready phases to process?
- If yes: Go back to §4.1 to process next ready phase(s)
- If no more phases: Proceed to §5.0 Finalize

### 4.4 SEQUENTIAL EXECUTION FLOW

**d1. Announce:** "Executing tasks from plan.md following workflow.md procedures."

**d2. Iterate Through Tasks:** Loop through each task in `plan.md` one by one.

**d3. For Each Task:**
- **i. Defer to Workflow:** `workflow.md` is the **single source of truth** for task lifecycle. Follow its "Task Workflow" and "TDD Cycle" sections for implementation, testing, and committing.
  - **CRITICAL: NEVER run `git push`. All commits stay local. Users decide when to push.**
- **ii. Update Implementation State:** After marking task in progress:
  - Set `current_phase` to current phase name
  - Set `current_phase_index` to current phase number (zero-based)
  - Set `current_task_index` to current task number within the phase (zero-based)
  - Set `last_updated` to current ISO8601 timestamp
  - Set `status` to "in_progress"
- **iii. On Phase Completion:** When all tasks in a phase are complete:
  - Add phase name to `completed_phases` array
  - Reset `current_task_index` to 0
  - **Check phase graph for next ready phases:**
    - If other phases now have all dependencies met → Go back to §4.1
    - If next sequential phase is ready → Process it
    - If all phases complete → Proceed to §5.0 Finalize

**d4. Handle Blocked Tasks:**
- If task marked `[!]`:
  > "⚠️ Task is blocked: [reason]"
  > "What would you like to do?"
  > A) Skip this task and continue
  > B) Mark as unblocked and proceed
  > C) Stop implementation here
- If B: Change `[!]` to `[~]` and proceed
- If C: HALT and await user instructions

**d5. Self-Check & Issue Handling:**
- After implementation, run tests per `workflow.md` TDD cycle. Verify coverage meets `workflow.md` target (>=80% default). Run linting/type checks **only if** `tech-stack.md` or `workflow.md` indicates them — the default workflow has no lint/type steps.
- If issues found, analyze the root cause:

**Issue Analysis Decision Tree:**

| Issue Type | Indicators | Action |
|------------|------------|--------|
| **Implementation Bug** | Typo, logic error, missing import, test assertion wrong | Fix directly and continue |
| **Spec Issue** | Requirement wrong, missing, impossible, edge case not covered | Trigger Revision → update spec.md → log in revisions.md → then fix |
| **Plan Issue** | Missing task, wrong order, task too big/small, dependency missing | Trigger Revision → update plan.md → log in revisions.md → continue |
| **Discovered Work** | Bug found, improvement needed, follow-up task | Create follow-up task in plan.md or track separately |
| **Blocked** | External dependency, need user input, waiting on API | Mark as blocked `[!]`, suggest unblock path |

**Agent MUST announce:** "This issue reveals [spec/plan problem | implementation bug | discovered work]. [Triggering revision | Fixing directly | Created follow-up task]."

**For Spec/Plan Issues — Revision Protocol:**
1. Create/append to `./milefuon/tracks/<track_id>/revisions.md` with:
   - Revision number, date, type (Spec/Plan/Both)
   - What triggered the revision
   - Current phase/task when issue occurred
   - Changes made and rationale
   See `references/revision-log.md` for format.
2. Update the relevant document (`spec.md` or `plan.md`)
3. Add "Last Revised: YYYY-MM-DD" marker at top of updated file
4. Commit revision before continuing

---

## 5.0 FINALIZE TRACK

**PROTOCOL: Mark track as complete.**

1. After all tasks complete, update `./milefuon/tracks.md`: `## [~]` → `## [x]` for this track
2. **Clean Up State:** Set `implement_state.json:status` to `"completed"` with `last_updated` = now, then delete `./milefuon/tracks/<track_id>/implement_state.json` and `./milefuon/tracks/<track_id>/parallel_state.json` if it still exists
3. Announce track fully complete: "Track '<track_id>: <description>' is now complete. Run `milefuon-archive` to synchronize documentation and archive the track."

> **Note:** Documentation synchronization and archival are handled by `milefuon-archive`, not this skill. This skill only marks completion and cleans up its own state.

---

## 6.0 LEARNINGS CAPTURE (After Each Task)

**PROTOCOL: Record learnings and patterns discovered during implementation.**

After marking each task `[x]` complete, append to `./milefuon/tracks/<track_id>/learnings.md`:

```markdown
## [YYYY-MM-DD HH:MM] - Phase N Task M: <task_name>
Thread: $THREAD_ID (or $AMP_CURRENT_THREAD_ID if available)
- **Implemented:** <brief description of what was done>
- **Files changed:** <list of files modified/created>
- **Commit:** <sha_7chars>
- **Learnings:**
  - Patterns: <reusable patterns discovered, e.g., "this codebase uses X for Y">
  - Gotchas: <things to watch out for, e.g., "don't forget to update Z when changing W">
  - Context: <useful context, e.g., "the settings panel is in component X">
---
```

---

## 6.1 PATTERN ELEVATION (At Phase/Track Completion)

1. **Review Learnings:** Scan `learnings.md` for reusable patterns
2. **Identify Candidates:** Look for:
   - Patterns mentioned 2+ times
   - Gotchas that apply beyond this track
   - Context that future tracks would benefit from
3. **Prompt for Elevation:**
   > "I found these potentially reusable patterns from this phase/track:"
   >
   > | Pattern | Occurrences | Elevate to project? |
   > |---------|-------------|---------------------|
   > | "Use Zod for validation" | 3 | ☐ |
   > | "Barrel exports required" | 2 | ☐ |
   >
   > "Select patterns to add to `milefuon/patterns.md` (Enter numbers, or 'all', or 'skip'):"
4. **Stage Patterns for Archive (do NOT write directly):**
   - If patterns selected, append to `./milefuon/tracks/<track_id>/learnings.md` under `## Patterns Staged for Archive`:
     ```markdown
     ## Patterns Staged for Archive (pending >=2 occurrences, archive will persist)

     - <pattern description> (from: <track_id>, <date>) — occurrences: <N>
     ```
   - Do NOT write directly to `./milefuon/patterns.md` — that file is owned by `milefuon-archive` (persists only patterns with >=2 occurrences). The staged section is the handoff.
   - If no prior staged section exists, create it at the end of `learnings.md`.
5. **Suggest Module Updates:**
   - If learnings are specific to a module/directory:
     > "These learnings are specific to `src/auth/`. Would you like to update `src/auth/AGENT.md`?"
     > A) Yes - Add learnings to module AGENT.md
     > B) No - Keep in track learnings only
   - If A: Create/update the module's `AGENT.md` with relevant patterns

---

## 7.0 RED FLAGS

| Thought | Reality |
|---------|---------|
| "I'll implement without reading plan.md first" | Plan is the binding argument for the spec. Skipping it = building the wrong thing. |
| "I'll deviate from the plan where it makes sense" | Deviate = untracked work. If plan is wrong, fix plan first (revision log), then continue. |
| "I'll batch all tests at the end" | TDD means test-first per task. Batch testing is not TDD. |
| "I'll skip learnings for small tasks" | Small gets forgotten. Learnings compound across tracks. |
| "I don't need to check dependencies" | Skipped dep = broken track. Always verify depends_on. |
| "I'll push/cleanup without asking" | Git operations are user choice. NEVER run git push. Archive handles cleanup. |
| "Parallel tasks can share files" | Exclusive file ownership required. Conflicts must be resolved before spawning workers. |

---

## File Ownership

| File | Created by | Updated by |
|------|-----------|------------|
| `./milefuon/tracks/<id>/plan.md` | `milefuon-newtrack` | `milefuon-implement` (mark [x], revisions) |
| `./milefuon/tracks/<id>/spec.md` | `milefuon-newtrack` | `milefuon-implement` (revisions only) |
| `./milefuon/tracks/<id>/learnings.md` | `milefuon-newtrack` | `milefuon-implement` (append per task + staged patterns for archive) |
| `./milefuon/tracks/<id>/revisions.md` | `milefuon-implement` | `milefuon-implement` |
| `./milefuon/tracks/<id>/implement_state.json` | `milefuon-implement` | `milefuon-implement` (delete on done) |
| `./milefuon/tracks/<id>/parallel_state.json` | `milefuon-implement` | `milefuon-implement` (delete on done) |
| `./milefuon/tracks.md` | `milefuon-setup` | `milefuon-newtrack` (append), `milefuon-implement` (`[ ]→[~]→[x]`), `milefuon-archive` (remove) |
| `./milefuon/patterns.md` | `milefuon-setup` | `milefuon-archive` only (implement stages suggestions in `learnings.md`, archive persists >=2) |
| `./milefuon/product.md` | `milefuon-setup` | `milefuon-archive` only |
| `./milefuon/tech-stack.md` | `milefuon-setup` | `milefuon-archive` only |
| `./milefuon/workflow.md` | `milefuon-setup` | `milefuon-archive` only |

## Status Markers Reference

- `[ ]` - Pending
- `[~]` - In Progress
- `[x]` - Completed
- `[!]` - Blocked
