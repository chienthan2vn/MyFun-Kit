---
description: Validate Conductor project integrity
---

# Conductor Validate

Validate the integrity of this Conductor project.

## 1. Core Files Check

Verify these files exist in `conductor/`:
- `product.md`
- `tech-stack.md`
- `workflow.md`
- `tracks.md`

## 2. Tracks Consistency

For each track in `tracks.md`:
- Verify directory exists: `conductor/tracks/<track_id>/`
- Verify files: `metadata.json`, `spec.md`, `plan.md`
- Validate metadata.json has: track_id, type, status, created_at

## 3. Orphan Detection

- List all directories in `conductor/tracks/`
- Report any not referenced in `tracks.md`

## 4. Status Consistency

- Compare status markers in `tracks.md` with `metadata.json` status field
- Report mismatches

## 5. Plan Integrity

For each `plan.md`:
- Must have at least one phase and task
- Valid markers only: `[ ]`, `[~]`, `[x]`, `[!]`
- Completed tracks should have all tasks completed
- Validate parallel execution annotations if present

## 5a. Parallel Execution Validation

For tracks with parallel execution annotations:
- Check `<!-- execution: parallel -->` is after valid phase heading
- Verify all tasks in parallel phases have `<!-- files: ... -->` annotation
- Detect file conflicts (same file in multiple tasks)
- Verify `<!-- depends: ... -->` references valid task IDs
- If `parallel_state.json` exists, check for stale/orphan workers

## 6. Report

Present summary with:
- ✅ Valid items
- ⚠️ Warnings
- ❌ Errors
- Recommendations for fixes

## 7. Auto-Fix Option

Offer to fix auto-fixable issues:
- Missing metadata fields
- Status mismatches
- Orphan cleanup
- Template integrity issues

## 8. Template Validation

Verify template integrity:
- Check `conductor/templates/` directory exists
- For each template, verify `metadata.json`, `spec.template.md`, and `plan.template.md` are present
- Check for unresolved `{{variable}}` placeholders in template files
- Report any templates with missing or malformed files

## 9. Exploration Validation

Verify exploration workspace:
- Check `conductor/explorations/` directory structure
- Report any orphaned exploration directories (no metadata.json)
- No action needed for clean explorations - they are ephemeral by design
