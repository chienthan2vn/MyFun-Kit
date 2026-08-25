---
description: Update spec/plan when implementation reveals issues
---

# Conductor Revise

Update specifications and plans when implementation reveals issues, requirements change, or scope adjustments are needed.

## 1. Identify Track
- Find active track (marked `[~]` in tracks.md)
- If no active track, ask which track to revise
- Check for `parallel_state.json` (parallel execution in progress)

## 1a. Parallel Execution Check

If `parallel_state.json` exists:
> "⚠️ This track has parallel workers currently running."
> "Revising the plan may affect in-progress workers."
> 
> "A) Wait for workers to complete, then revise"
> "B) Revise now (affected workers may need restart)"
> "C) Cancel revision"

- If A: Monitor until complete, then proceed
- If B: Note affected tasks in revision, workers operating on changed tasks should abort
- If C: HALT

## 2. Determine Revision Type
Ask what needs revision:
1. **Spec** - Requirements changed or misunderstood
2. **Plan** - Tasks need to be added, removed, or modified
3. **Both** - Significant scope change

## 3. Gather Context
Ask targeted questions about what was discovered and what needs to change.

## 4. Create Revision Record
Append to `conductor/tracks/<track_id>/revisions.md`:
- Revision number, date, type
- What triggered the revision
- Current phase/task when revision occurred
- Changes made (spec and/or plan)
- Rationale and impact

## 5. Update Documents
- Update `spec.md` and/or `plan.md` as needed
- Add "Last Revised" marker at top of updated files
- New tasks: `[ ]`, Removed tasks: `[-] [REMOVED: reason]`
- **Phase-level parallel changes:**
  - Add/modify `<!-- depends: -->` annotations for phase dependencies
  - Add/modify `<!-- depends: phase1, phase2 -->` for specific phase dependencies
  - If removing a phase that others depend on, update dependent phases
- **Task-level parallel changes:**
  - Update `<!-- files: ... -->` and `<!-- depends: ... -->` annotations
  - If parallel phase removed: Mark for sequential execution or update annotations

## 6. Commit
```bash
git add conductor/tracks/<track_id>/
git commit -m "conductor(revise): Update spec/plan for <track_id>"
```

## 7. Announce
Report what was revised and suggest `/conductor-implement` to continue.

---

## 7a. LOG REVISION AS LEARNING

**PROTOCOL: Record revisions as learnings for future tracks (Ralph-style gotcha tracking).**

Revisions are valuable learnings - they indicate gaps in initial understanding.

1. **Append to `learnings.md`:**
   ```markdown
   ## [YYYY-MM-DD HH:MM] - REVISION #N
   Thread: $AMP_CURRENT_THREAD_ID
   - **Type:** Spec/Plan/Both
   - **Trigger:** <what triggered the revision during implementation>
   - **Learning:**
     - Gotcha: <what was missed or misunderstood>
     - Pattern: <how to avoid this in future - e.g., "always verify X before starting Y">
   ---
   ```

2. **Flag for Pattern Elevation:**
   - If revision reveals a pattern applicable to future tracks:
     > "This revision reveals a reusable lesson. Add to project patterns?"
     > - "<lesson description>"
     > (yes/no)
   - If yes: Append to `conductor/patterns.md`

