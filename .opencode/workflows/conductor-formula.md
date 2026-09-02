---
description: List and manage track workflow templates
argument-hint: [list|show <name>]
---

<!-- 
SYSTEM DIRECTIVE: You are an AI agent for the Conductor framework.
CRITICAL: Validate every tool call. If any fails, halt and announce the failure.
-->

# Conductor Formula

Manage track workflow templates: $ARGUMENTS

---

## 1.0 PARSE SUBCOMMAND

**PROTOCOL: Determine action from arguments.**

1. **Parse $ARGUMENTS:**

   **If empty or "list":**
   - Go to section 2.0 (List Templates)

   **If "show <name>":**
   - Extract template name
   - Go to section 3.0 (Show Template Details)

   **If "create":**
   - Announce: "To create a new template, use `/conductor-distill <track_id>` to extract a template from a completed track."
   - HALT

   **Otherwise:**
   - Announce available subcommands:
     > "Usage: /conductor-formula [list|show <name>]"
     > 
     > **Subcommands:**
     > - `list` - List all available templates (default)
     > - `show <name>` - Show template structure and variables
     > 
     > **Related commands:**
     > - `/conductor-distill <track_id>` - Create template from completed track
     > - `/conductor-explore <name>` - Quick ephemeral exploration track
   - HALT

---

## 2.0 LIST TEMPLATES

**PROTOCOL: Display available workflow templates.**

1. **Scan Template Directory:**
   - List all directories in `conductor/templates/`
   - Each directory represents a template

2. **Handle Empty Result:**
   - If no templates found:
     > "No templates found in `conductor/templates/`."
     > 
     > **To create a template:**
     > 1. Complete a track using `/conductor-implement`
     > 2. Run `/conductor-distill <track_id>` to extract a reusable template

3. **Display Results:**
   For each template directory, read `metadata.json` to get name, description, and variables.
   > "## Available Templates (Track Templates)"
   > 
   > | Template | Description | Variables |
   > |----------|-------------|-----------|
   > | `<name>` | `<description>` | `<var_list>` |
   > 
   > **Usage:**
   > - `/conductor-formula show <name>` - View template details
   > - `/conductor-init <name> --var key=value` - Create new track from template
   > - `/conductor-explore <name> --var key=value` - Quick ephemeral exploration from template

---

## 3.0 SHOW TEMPLATE DETAILS

**PROTOCOL: Display template structure and required variables.**

1. **Read Template Files:**
   - Check if `conductor/templates/<template_name>/` exists
   - Read `metadata.json`, `spec.template.md`, `plan.template.md`

2. **Handle Not Found:**
   - If template not found:
     > "Template '<name>' not found."
     > "Run `/conductor-formula list` to see available templates."
   - HALT

3. **Display Structure:**
   > "## Template: <name>"
   > 
   > **Description:** <description>
   > 
   > ### Variables
   > | Variable | Default | Description | Required |
   > |----------|---------|-------------|----------|
   > | `{{var1}}` | `<default>` | `<desc>` | true/false |
   > 
   > ### Template Spec Preview
   > ```
   > <first 50 lines of spec.template.md>
   > ```
   > 
   > ### Template Plan Preview
   > ```
   > <first 50 lines of plan.template.md>
   > ```
   > 
   > ### Usage Examples
   > ```bash
   > # Create persistent track (auditable, synced to git)
   > /conductor-init <name> --var key=value
   > 
   > # Create ephemeral exploration (no audit trail)
   > /conductor-explore <name> --var key=value
   > ```

---

## 4.0 CONDUCTOR INTEGRATION NOTES

**PROTOCOL: Explain how templates work with Conductor.**

After listing or showing templates, include:

> ### How Templates Work with Conductor
> 
> Conductor templates are reusable workflow templates stored in `conductor/templates/`. When you complete a track, you can extract it as a template for reuse.
> 
> | Conductor Concept | Description |
> |-------------------|-------------|
> | **Template** | Reusable track pattern in `conductor/templates/` |
> | **Track** | Feature track (persistent, auditable) |
> | **Exploration** | Quick exploration (ephemeral, no clutter) |
> 
> **Workflow:**
> 1. Create and complete a track: `/conductor-newtrack` → `/conductor-implement`
> 2. Extract as template: `/conductor-distill <track_id>`
> 3. Reuse for new work: `/conductor-init <template>` or `/conductor-explore <template>`