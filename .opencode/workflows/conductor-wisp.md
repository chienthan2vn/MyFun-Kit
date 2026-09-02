---
description: Create ephemeral exploration track (no audit trail)
argument-hint: [template_name] [--var key=value]
---

<!-- 
SYSTEM DIRECTIVE: You are an AI agent for the Conductor framework.
CRITICAL: Validate every tool call. If any fails, halt and announce the failure.
-->

# Conductor Explore

Create ephemeral exploration track: $ARGUMENTS

---

## 1.0 UNDERSTAND EXPLORATIONS

**PROTOCOL: Explain ephemeral exploration tracks.**

Explorations are **ephemeral** workflow instances that:
- Live in `conductor/explorations/<timestamp>/` (separate from `conductor/tracks/`)
- Are **never** synced to git (add to `.gitignore`)
- Leave no permanent audit trail
- Perfect for exploration, debugging, quick fixes

**Use explorations when:**
- Exploring an approach before committing to it
- Quick debugging session
- Temporary work that shouldn't clutter history
- Patrol cycles, health checks, routine monitoring

**Use persistent tracks (`/conductor-newtrack`) when:**
- Feature development
- Bug fixes that need audit trail
- Work spanning multiple sessions
- Team coordination required

---

## 2.0 CREATE EXPLORATION

**PROTOCOL: Create ephemeral exploration track.**

### 2.1 Parse Arguments

**If template name provided:**
- Use the specified template from `conductor/templates/`
- Extract any `--var key=value` arguments

**If no template name:**
1. **List Available Templates:**
   - Read directories in `conductor/templates/`
   - Read `metadata.json` from each

2. **If templates exist:**
   > "Available templates for exploration:"
   > 
   > | # | Template | Description |
   > |---|----------|-------------|
   > | 1 | `<name>` | `<desc>` |
   > 
   > "Enter template number or name, or describe what you want to explore:"

3. **If no templates:**
   > "No templates found. Creating ad-hoc exploration."
   > "What do you want to explore? (Describe briefly)"
   - Wait for user input
   - Go to section 2.3 (Ad-hoc Exploration)

### 2.2 Create Exploration from Template

1. **Generate Exploration ID:**
   - Format: `explore_YYYYMMDD_HHMMSS`
   - Create directory: `conductor/explorations/<exploration_id>/`

2. **Read Template Files:**
   - Read `conductor/templates/<template_name>/metadata.json`
   - Read `conductor/templates/<template_name>/spec.template.md`
   - Read `conductor/templates/<template_name>/plan.template.md`

3. **Substitute Variables:**
   - Replace `{{variable}}` placeholders with provided `--var` values
   - For required variables without values, prompt user

4. **Create Exploration Files:**
   - `conductor/explorations/<exploration_id>/spec.md` (from template)
   - `conductor/explorations/<exploration_id>/plan.md` (from template)
   - `conductor/explorations/<exploration_id>/metadata.json`:
     ```json
     {
       "exploration_id": "<exploration_id>",
       "template": "<template_name>",
       "created_at": "<timestamp>",
       "status": "active",
       "variables": { "key": "value" }
     }
     ```

5. **Ensure .gitignore:**
   - If `conductor/explorations/` not in `.gitignore`, add it

6. **Announce:**
   > "## Ephemeral Exploration Started"
   > 
   > **Exploration ID:** `<exploration_id>`
   > **Template:** `<template_name>`
   > **Location:** `conductor/explorations/<exploration_id>/`
   > 
   > **Current Plan:**
   > (Display first few tasks from plan.md)
   > 
   > **Remember:** This exploration is ephemeral - it won't be synced to git.
   > 
   > **When done:**
   > - Run `/conductor-explore save <exploration_id>` - Create digest of findings
   > - Run `/conductor-explore burn <exploration_id>` - Delete without trace
   > - Run `/conductor-explore promote <exploration_id>` - Convert to persistent track

### 2.3 Create Ad-hoc Exploration

If no template specified and user describes exploration:

1. **Generate Exploration ID:**
   - Format: `explore_YYYYMMDD_HHMMSS`
   - Create directory: `conductor/explorations/<exploration_id>/`

2. **Create Basic Files:**
   - `spec.md` with user's description
   - `plan.md` with minimal structure:
     ```markdown
     # Exploration Plan: <description>

     ## Phase 1: Investigate

     - [ ] Define the problem space
     - [ ] Explore potential approaches
     - [ ] Document findings

     ## Phase 2: Decide

     - [ ] Evaluate options
     - [ ] Choose direction or burn
     ```
   - `metadata.json`:
     ```json
     {
       "exploration_id": "<exploration_id>",
       "template": null,
       "created_at": "<timestamp>",
       "status": "active",
       "description": "<user_description>"
     }
     ```

3. **Announce:**
   > "## Ad-hoc Exploration Started"
   > 
   > **Exploration ID:** `<exploration_id>`
   > **Topic:** `<description>`
   > 
   > This is an ephemeral exploration. Add tasks as you discover work.
   > 
   > When done:
   > - `/conductor-explore save <exploration_id>` - Create digest of findings
   > - `/conductor-explore burn <exploration_id>` - Delete without trace

---

## 3.0 EXPLORATION MANAGEMENT

**PROTOCOL: Commands for managing active explorations.**

### List Active Explorations

- List directories in `conductor/explorations/`
- Read `metadata.json` for each
- Display:
  > "## Active Explorations"
  > 
  > | ID | Template | Created | Status |
  > |----|----------|---------|--------|
  > | `<id>` | `<template>` | `<timestamp>` | active |

### Save Exploration (Create Digest)

When exploration yields useful findings:

1. **Prompt for Summary:**
   > "Summarize your key findings (or press Enter to skip):"

2. **Create Digest:**
   - Create `conductor/explorations/<exploration_id>/digest.md`:
     ```markdown
     # Exploration Digest: <exploration_id>
     
     **Template:** <template_name or "ad-hoc">
     **Date:** <timestamp>
     **Summary:** <user_summary>
     
     ## Key Findings
     
     <from user or extracted from spec/plan>
     
     ## Next Steps
     
     <recommendations>
     ```
   - Update `metadata.json`: `"status": "completed"`

3. **Announce:**
   > "Exploration digest saved to `conductor/explorations/<exploration_id>/digest.md`"
   > "You can now promote this to a track with `/conductor-explore promote <exploration_id>`"

### Burn Exploration (No Trace)

When exploration has no archival value:

1. **Confirm:**
   > "Delete exploration `<exploration_id>` completely? This cannot be undone. (yes/no)"

2. **If confirmed:**
   - Delete `conductor/explorations/<exploration_id>/`
   - Announce: "Exploration burned. No trace remains."

---

## 4.0 TRANSITION TO PERSISTENT TRACK

**PROTOCOL: Convert exploration to permanent track if valuable.**

If exploration reveals work worth tracking:

> "This exploration found valuable work. Would you like to:"
> 
> A) **Promote to persistent track** - Create full Conductor track from findings
> B) **Save digest only** - Keep findings, delete exploration workspace
> C) **Burn** - Discard exploration completely

**If A (Promote to track):**
1. Use `/conductor-newtrack` with exploration findings
2. Reference exploration discoveries in spec
3. Burn original exploration after track created

**If B (Save digest only):**
- Digest already created in step 3 above
- Burn exploration workspace

---

## 5.0 QUICK REFERENCE

> ### Exploration Quick Reference
> 
> | Action | Command |
> |--------|---------|
> | Create from template | `/conductor-explore <template>` |
> | Create ad-hoc | `/conductor-explore "Explore X"` |
> | List active | `/conductor-explore list` |
> | Save findings | `/conductor-explore save <id>` |
> | Promote to track | `/conductor-explore promote <id>` |
> | Delete completely | `/conductor-explore burn <id>` |
> 
> **Location:** All explorations in `conductor/explorations/`
> **Git:** Never committed (in .gitignore)