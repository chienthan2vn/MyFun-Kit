---
name: milefuon-archive
description: "Use when closing a completed Milefuon track, synchronizing overview docs, elevating patterns, and archiving artifacts. Triggers on \"archive track / close track / complete track\". Do NOT use for execution — that's milefuon-implement. Run after milefuon-implement marks [x]."
---

# Milefuon Archive

Close a completed track: synchronize overview files, elevate patterns, move artifacts to `archive/`, and clean up `tracks.md`.

<HARD-GATE>
Do NOT archive a track that is not [x] completed. Do NOT write to product.md / tech-stack.md / workflow.md / patterns.md without presenting the diff and receiving explicit approval. Do NOT skip the setup check or the completed-track check.
</HARD-GATE>

**Language Rule:** All overview file updates (`product.md`, `tech-stack.md`, `workflow.md`, `patterns.md`, `tracks.md`) and archival operations MUST be written in English. Conversational communication with the human partner (explanations, summaries, confirmations outside artifacts) is in Vietnamese.

**Path convention:** Inside skill → path from skill (`references/...`). Outside skill → path from project root (`./milefuon/...`, `./milefuon/archive/<id>/`).

---

## 1.0 SETUP CHECK

**PROTOCOL: Verify Milefuon environment and find completed tracks.**

1. **Read overview files in order:**
   - `./milefuon/product.md`
   - `./milefuon/tech-stack.md`
   - `./milefuon/workflow.md`
   - `./milefuon/patterns.md`
   - `./AGENT.md`
   - If ANY missing: **HALT** → Announce: "Milefuon is not set up. Please run `milefuon-setup` first."

2. **Read `./milefuon/tracks.md`:**
   - Split by `---` separator, extract per section: status `[ ]`/`[~]`/`[x]`/`[!]`, description, folder `./milefuon/tracks/<track_id>/`
   - If no `##` sections found: **HALT** → "The tracks file is empty or malformed."
   - If no `[x]` track found: **HALT** → "No completed tracks [x] found. Run `milefuon-implement` to complete a track first."

See `references/archive-checklist.md` for validation details.

---

## 2.0 TRACK SELECTION

**PROTOCOL: Select exactly which completed track(s) to archive. One or many, explicit.**

1. **List completed tracks:** All `## [x] Track:` entries with `track_id` and description.

2. **Resolve selection:**
   - If `$ARGUMENTS` provided: case-insensitive exact match against `track_id` or description. If no match → HALT with "No completed track matches '<args>'."
   - If `$ARGUMENTS` is `all`: select every `[x]` track.
   - If no args: select the first `[x]` track and confirm.

3. **Confirm:**
   > "I found track '<track_id>: <description>' marked [x] completed. Archive this track?"
   > A) **Archive** — Proceed
   > B) **Choose another** — Show list to pick
   > C) **Cancel** — Stop

4. **Pre-archive validation (per selected track):**
   - Verify `./milefuon/tracks/<track_id>/spec.md`, `plan.md`, `metadata.json`, `learnings.md` exist. If `plan.md` still has `[ ]`/`[~]`/`[!]` tasks → HALT → "Track '<id>' has incomplete tasks. Complete all tasks before archiving."
   - If `metadata.json` is empty/corrupted JSON → HALT → "Corrupted metadata file detected at ./milefuon/tracks/<track_id>/metadata.json."
   - **Stale state cleanup:** If `implement_state.json` or `parallel_state.json` still exists → warn "Stale state file detected at <path> — cleaning up." → delete it before moving.

---

## 3.0 SYNCHRONIZE OVERVIEW FILES

**PROTOCOL: Overview files are owned by archive, not implement. Present diff, get approval, then write.**

For each selected track, check if `spec.md` introduced changes that should propagate to overview files.

1. **Detect needed updates:**
   - `product.md` — scope / vision pivot (new goals, expanded product description)
   - `tech-stack.md` — new dependencies, framework changes
   - `workflow.md` — methodology / process changes
   - If no changes detected → skip to §4.0 and note "No overview updates needed."

2. **For each file that needs update:**
   - Draft the updated content (keep existing structure, patch only changed sections).
   - Present diff in chat:
     > "I've drafted update for `./milefuon/<file>` based on `<track_id>` spec. Please review:"
     > ```markdown
     > [full drafted content or diff]
     > ```
     > A) **Approve** — Write file
     > B) **Suggest Changes** — Tell me what to modify
   - Loop until **A**. On **B**, apply changes and re-present.
   - On **A**, write `./milefuon/<file>` and append `Last refreshed: YYYY-MM-DD` if not present.

> **Rule:** Never write to `product.md`/`tech-stack.md`/`workflow.md` without this gate. Setup creates them once; archive maintains them.

---

## 4.0 ELEVATE PATTERNS

**PROTOCOL: Stage → persist only if >=2 occurrences. Archive never writes speculative patterns.**

1. **Collect candidates:**
   - Read `./milefuon/tracks/<track_id>/learnings.md` — extract `## Patterns Staged for Archive` section (added by `milefuon-implement` §6.1) plus any `Patterns:`/`Gotchas:` lines.
   - Read `./milefuon/patterns.md` existing entries (for dedup).
   - Optionally scan `./milefuon/archive/*/learnings.md` to count occurrences across archived tracks.

2. **Count occurrences:** A pattern is counted if the same normalized text appears in >=2 tracks (active + archive). Normalize: trim, collapse whitespace, case-insensitive compare.

3. **Present elevation table (if candidates exist):**
   > "## Patterns staged from '<track_id>'"
   > | # | Pattern | Occurrences | Elevate to project? |
   > |---|---------|-------------|---------------------|
   > | 1 | "Use X for Y" | 2 | ☐ |
   > | 2 | "Don't forget Z" | 1 | — (needs 1 more) |
   > "Select patterns to add to `patterns.md` (Enter numbers, 'all', or 'skip'):"

4. **Update `patterns.md`:** For each selected pattern with `occurrences >=2`, append under the appropriate section (`## Code Conventions` / `## Architecture` / `## Gotchas` / `## Testing` — create section if missing):
   ```markdown
   - <pattern> (from: <track_id>, archived YYYY-MM-DD) — occurrences: <N>
   ```
   - Dedup: skip if normalized pattern already exists.
   - Ensure file ends with `Last refreshed: YYYY-MM-DD`.

See `references/pattern-elevation.md` for format and threshold details.

---

## 5.0 ARCHIVE MOVE

**PROTOCOL: Move track folder, remove from index. Idempotent.**

For each selected track (in selection order):

1. **Create archive dir:** `mkdir -p ./milefuon/archive` (idempotent).

2. **Collision check:** If `./milefuon/archive/<track_id>/` already exists → HALT → "Archive collision: ./milefuon/archive/<track_id> already exists. Remove or rename before archiving."

3. **Move:** `mv ./milefuon/tracks/<track_id>/ ./milefuon/archive/<track_id>/`
   - Verify exit code 0. On failure → HALT → "Archive move failed for '<track_id>' — check permissions."
   - Handle broken symlink like `scaffold.sh` (remove dangling link before mkdir/mv).

4. **Update `./milefuon/tracks.md`:** Remove the entire `## [x] Track: <desc>` section including its preceding `---` separator. If it was the last section, ensure file does not end with stray `---`.

5. **Verify:** Confirm `./milefuon/archive/<track_id>/learnings.md` still exists (preserved for future `milefuon-newtrack` seeding).

---

## 6.0 FINALIZE

**PROTOCOL: Commit locally, announce.**

1. **Commit (local only):**
   ```bash
   git add ./milefuon/product.md ./milefuon/tech-stack.md ./milefuon/workflow.md ./milefuon/patterns.md ./milefuon/tracks.md ./milefuon/archive/<track_id>/
   git commit -m "chore(milefuon): archive <track_id> — <description>"
   ```
   **CRITICAL: NEVER run `git push`. All commits stay local. User decides when to push.**

2. **Announce:**
   > "Track '<track_id>: <description>' archived. Overview files synchronized: <N>. Patterns elevated: <M>. Next: run `milefuon-newtrack` for a new track."

3. **If multiple tracks selected:** Repeat §3.0-§5.0 per track, then single commit for all.

---

## File Ownership

| File | Created by | Updated by |
|------|-----------|------------|
| `./AGENT.md` | `milefuon-setup` | `milefuon-setup` only |
| `./milefuon/product.md` | `milefuon-setup` | `milefuon-archive` only |
| `./milefuon/tech-stack.md` | `milefuon-setup` | `milefuon-archive` only |
| `./milefuon/workflow.md` | `milefuon-setup` | `milefuon-archive` only |
| `./milefuon/tracks.md` | `milefuon-setup` (empty) | `milefuon-newtrack` (append), `milefuon-implement` (`[ ]→[~]→[x]`), `milefuon-archive` (remove) |
| `./milefuon/patterns.md` | `milefuon-setup` | `milefuon-archive` only (persists >=2, implement stages in `learnings.md`) |
| `./milefuon/tracks/<id>/*` | `milefuon-newtrack` | `milefuon-implement` (tasks, learnings, revisions) |
| `./milefuon/archive/<id>/*` | `milefuon-archive` (via mv) | — (immutable after archival) |
| `./milefuon/tracks/<id>/implement_state.json` | `milefuon-implement` | `milefuon-implement` (archive cleans stale) |
| `./milefuon/tracks/<id>/parallel_state.json` | `milefuon-implement` | `milefuon-implement` (archive cleans stale) |

> Project file updates (`product.md`, `tech-stack.md`, `patterns.md`, `tracks.md`) are owned by `milefuon-archive`, not by per-task execution.

---

## Red Flags

| Thought | Reality |
|---------|---------|
| "I'll archive without verifying [x]" | Only `[x]` tracks may be archived |
| "I'll write to patterns.md for every learning" | Threshold = >=2 occurrences; stage in learnings.md, archive persists |
| "I'll update product.md while coding" | File ownership = milefuon-archive. Don't write directly. |
| "I'll skip the diff gate" | Every overview file update needs A/B approval |
| "I'll push after archiving" | Never push — local commit only |
| "Parallel tasks can share during archive" | Archive is sequential per track |

## References

- [archive-checklist.md](references/archive-checklist.md) — Pre-archive validation checklist (self-contained)
- [pattern-elevation.md](references/pattern-elevation.md) — Pattern threshold, dedup, and format (self-contained)
