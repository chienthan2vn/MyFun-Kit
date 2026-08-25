---
description: Archive completed tracks
---

# Conductor Archive

Archive completed tracks to clean up the project.

## 1. Find Completed Tracks
List all `[x]` tracks from `tracks.md`.

## 2. Select Tracks
- Archive all completed
- Or select specific ones
- Or cancel

## 3. Archive Process
For each selected track:
1. Create `conductor/archive/` if needed
2. **Check for stale parallel state**: If `parallel_state.json` exists, warn and clean up
3. **Extract learnings before archiving** (see step 3a)
4. Move track folder to archive
5. Remove from `tracks.md`
6. Add archive comment

### 3a. Extract Learnings Before Archiving

**PROTOCOL: Preserve learnings from completed tracks (Ralph-style knowledge capture).**

1. **Read Track Learnings:** Load `conductor/tracks/<track_id>/learnings.md`

2. **Identify Patterns to Elevate:**
   - Find patterns not yet in `conductor/patterns.md`
   - Find gotchas with general applicability
   
3. **Present Extraction Summary:**
   > "## Learnings from `<track_id>`"
   > 
   > **Patterns to preserve:**
   > | Pattern | Elevate to project? |
   > |---------|---------------------|
   > | "Use X for Y" | ☐ |
   > | "Don't forget Z" | ☐ |
   > 
   > "Select patterns to add to `conductor/patterns.md` (Enter numbers, 'all', or 'skip'):"

4. **Update Project Patterns:**
   - Append selected patterns to `conductor/patterns.md`:
     ```markdown
     - <pattern> (from: <track_id>, archived <date>)
     ```

5. **Preserve Learnings in Archive:**
   - Keep `learnings.md` in the archived track folder
   - Future tracks can reference via `/conductor-newtrack`

## 4. Commit
Commit the archive operation.