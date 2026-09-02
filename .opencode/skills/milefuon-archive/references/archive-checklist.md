# Archive Checklist

Self-contained pre-archive validation. Recreated for Milefuon — no external link.

## 1. Overview files exist

Check all 4 exist before archiving:
- `./milefuon/product.md`
- `./milefuon/tech-stack.md`
- `./milefuon/workflow.md`
- `./milefuon/patterns.md`

If any missing → HALT: "Milefuon is not set up. Please run `milefuon-setup` first."

## 2. tracks.md parsing

- Read `./milefuon/tracks.md` as text.
- Split by line `---` (exact, trimmed) to get sections.
- Each `## [x] Track:` section must contain: status marker, description after `Track:`, and folder link `./milefuon/tracks/<track_id>/`.
- Extract `track_id` from folder link (`tracks/<id>/`).
- Markers: `[ ]` pending, `[~]` in progress, `[x]` completed, `[!]` blocked. Only `[x]` is archivable.

Malformed cases:
- No `##` sections → HALT: "The tracks file is empty or malformed."
- No `[x]` → HALT: "No completed tracks [x] found."
- Duplicate `track_id` → HALT: "Duplicate track_id '<id>' in tracks.md."

## 3. Track folder validation (per selected track)

Required files:
- `./milefuon/tracks/<id>/spec.md` — must exist, non-empty
- `./milefuon/tracks/<id>/plan.md` — must exist, every task line `-[ ]`/`-[~]`/`-[!]` is forbidden; only `-[x]` allowed
- `./milefuon/tracks/<id>/metadata.json` — must be valid JSON with fields `id` or `track_id`, `description`, `status`. If empty/corrupted → HALT: "Corrupted metadata file detected at ./milefuon/tracks/<id>/metadata.json."
- `./milefuon/tracks/<id>/learnings.md` — should exist (warn if missing, continue)

Optional but preserved: `revisions.md`, `handoff_*.md`

## 4. Stale state cleanup

Before `mv`, check inside track folder:
- `implement_state.json` — should be deleted by implement on done. If exists → warn + delete.
- `parallel_state.json` — same. Warn "Stale state file detected at ./milefuon/tracks/<id>/parallel_state.json — cleaning up." → delete.

If `parallel_state.json` still has `in_progress` older than 60 min → treat as stale.

## 5. Idempotent filesystem ops

- `mkdir -p ./milefuon/archive` — idempotent.
- Before `mv`, handle broken symlink: `if [ -L ./milefuon/archive/<id> ] && [ ! -e ./milefuon/archive/<id> ]; then rm ./milefuon/archive/<id>; fi`
- After `mv`, verify `0` exit code.

## 6. tracks.md removal rule

- Remove the entire section `## [x] Track: ...` plus its preceding `---` (if not first section).
- If last track removed, trim trailing `---` and blank lines.
- Keep file valid: at least header remains (`# Tracks` etc.) or recreate empty template if scaffold expected.
