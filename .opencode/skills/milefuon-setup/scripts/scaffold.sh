#!/usr/bin/env bash
# scaffold.sh — Idempotent scaffold for milefuon/ folder.
# Creates tracks/, archive/, templates symlink, tracks.md, patterns.md.
# Safe to re-run: skips files that already exist.
# Path convention: outside skill → path from project root (./milefuon/...)
set -e

# Create directories
mkdir -p ./milefuon/tracks ./milefuon/archive

# Clean up broken symlink if exists
if [ -L ./milefuon/templates ] && [ ! -e ./milefuon/templates ]; then
  echo "Cleaning up broken symlink: ./milefuon/templates"
  rm -f ./milefuon/templates
fi

# Locate templates directory from multiple candidate locations
TEMPLATES_SRC=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CANDIDATES=(
  "./.opencode/skills/milefuon-newtrack/templates"
  "./.claude/skills/milefuon-newtrack/templates"
  "./.agents/skills/milefuon-newtrack/templates"
)

for cand in "${CANDIDATES[@]}"; do
  if [ -d "$cand" ]; then
    TEMPLATES_SRC="$cand"
    break
  fi
done

# Symlink or copy templates if not present
if [ ! -e ./milefuon/templates ] && [ ! -L ./milefuon/templates ]; then
  if [ -n "$TEMPLATES_SRC" ]; then
    # Calculate target path relative to ./milefuon directory
    SYMLINK_TARGET="$TEMPLATES_SRC"
    if [[ "$TEMPLATES_SRC" == ./* ]]; then
      SYMLINK_TARGET="../${TEMPLATES_SRC#./}"
    fi

    if ln -s "$SYMLINK_TARGET" ./milefuon/templates 2>/dev/null; then
      echo "Created symlink: ./milefuon/templates -> $SYMLINK_TARGET"
    else
      # Fallback: copy
      mkdir -p ./milefuon/templates
      cp -r "$TEMPLATES_SRC/." ./milefuon/templates/ 2>/dev/null || true
      echo "Copied templates to ./milefuon/templates/ (symlink failed)"
    fi
  else
    echo "WARNING: milefuon-newtrack templates not found in candidate paths. Skipping templates." >&2
  fi
fi

# Default tracks.md (only if not exists)
if [ ! -f ./milefuon/tracks.md ]; then
  cat > ./milefuon/tracks.md <<'EOF'
# Project Tracks

This file tracks all major tracks for the project.

<!-- Tracks will be appended here by milefuon-newtrack -->
EOF
  echo "Created ./milefuon/tracks.md"
fi

# Default patterns.md (only if not exists)
if [ ! -f ./milefuon/patterns.md ]; then
  TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%d)"
  cat > ./milefuon/patterns.md <<EOF
# Codebase Patterns

Reusable patterns discovered during development. Read this before starting new work.

## Code Conventions
<!-- Patterns will be added as tracks are completed -->

## Architecture
<!-- Patterns will be added as tracks are completed -->

## Gotchas
<!-- Patterns will be added as tracks are completed -->

## Testing
<!-- Patterns will be added as tracks are completed -->

---
Last refreshed: $TIMESTAMP
EOF
  echo "Created ./milefuon/patterns.md"
fi

echo "Scaffold complete."
