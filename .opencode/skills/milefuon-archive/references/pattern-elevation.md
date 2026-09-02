# Pattern Elevation

Self-contained pattern threshold, dedup, and format. No link to `milefuon-implement` refs — recreated for Milefuon archive.

## 1. Threshold

- A pattern is elevated to `./milefuon/patterns.md` **only if occurrences >= 2** across tracks.
- Occurrences = count of same normalized pattern text found in:
  - `./milefuon/tracks/<id>/learnings.md` staged section
  - `./milefuon/archive/*/learnings.md` (all archived tracks)
- Normalize for compare: trim, collapse inner whitespace to single space, case-insensitive.

## 2. Candidate sources

- Primary: `./milefuon/tracks/<id>/learnings.md` section:
  ```markdown
  ## Patterns Staged for Archive (pending >=2 occurrences, archive will persist)
  - <pattern> — occurrences: <N>
  ```
  Added by `milefuon-implement` §6.1. Each bullet is a candidate.

- Secondary: Any `Patterns:` / `Gotchas:` bullets in `learnings.md` body.

If no candidates → skip elevation with note "No patterns staged for this track."

## 3. Dedup

Before appending, normalize candidate and compare against existing lines in `./milefuon/patterns.md`:
- Strip attributes ` (from: ...)` and ` — occurrences: ...` before compare.
- If normalized already exists → skip, note "Already in patterns.md."

## 4. Section placement

`patterns.md` has sections created by `scaffold.sh`:

```markdown
## Code Conventions
## Architecture
## Gotchas
## Testing
```

- Place each pattern under the most fitting section (default: `## Gotchas` if unclear).
- Create section if missing.
- Keep bullets sorted or appended at end of section.

## 5. Format

Append exactly:

```markdown
- <pattern> (from: <track_id>, archived YYYY-MM-DD) — occurrences: <N>
```

Example:
```markdown
- Use Zod for all API input validation (from: 003-auth-tokens, archived 2026-09-02) — occurrences: 2
```

## 6. Presentation gate

Present table:

| # | Pattern | Occurrences | Elevate? |
|---|---------|-------------|----------|
| 1 | "Use X" | 2 | ☐ |
| 2 | "Don't Y" | 1 | — (needs 1 more) |

Prompt: "Select patterns to add to `patterns.md` (Enter numbers, 'all', or 'skip'):"

- `all` → elevate every candidate with `>=2`.
- `skip` → none.
- Numbers → only those.

## 7. Last refreshed

After any elevation, ensure `./milefuon/patterns.md` ends with:

```markdown
---
Last refreshed: YYYY-MM-DD
```

If already present, update date. If missing, append.

## 8. Preservation

- Keep `learnings.md` inside `./milefuon/archive/<id>/` unchanged after move — future `milefuon-newtrack` can seed from it.
- Do NOT delete staged section; it serves as audit trail.
