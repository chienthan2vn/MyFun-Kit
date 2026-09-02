#!/usr/bin/env bash
# detect-brownfield.sh — Detect Brownfield vs Greenfield project.
# Output: BROWNFIELD or GREENFIELD on stdout.
#         Inferred stack details on stderr if brownfield.
# Exit: always 0.
set -e

BROWNFIELD=0
INFERRED=""

# Dependency manifests
MANIFESTS=(
  package.json pom.xml requirements.txt go.mod Cargo.toml pubspec.yaml
  pyproject.toml setup.py Pipfile pnpm-workspace.yaml deno.json bun.lockb yarn.lock
  CMakeLists.txt Makefile build.gradle build.gradle.kts Gemfile composer.json mix.exs
)

for f in "${MANIFESTS[@]}"; do
  if [ -f "$f" ]; then
    BROWNFIELD=1
    INFERRED="${INFERRED} $f"
  fi
done

# Source directories with code files
DIRS=(src app lib packages apps services backend frontend client server modules components)
EXTS=(ts js py go rs java rb cpp c cs php kt swift)

for d in "${DIRS[@]}"; do
  if [ -d "$d" ]; then
    found=""
    for ext in "${EXTS[@]}"; do
      if [ -n "$(find "$d" -maxdepth 4 -name "*.${ext}" -print -quit 2>/dev/null)" ]; then
        found=1
        break
      fi
    done
    if [ -n "$found" ]; then
      BROWNFIELD=1
      INFERRED="${INFERRED} src=$d"
    fi
  fi
done

if [ "$BROWNFIELD" = "1" ]; then
  echo "BROWNFIELD"
  if [ -n "$INFERRED" ]; then
    # Trim leading space
    INFERRED_TRIMMED="$(echo "$INFERRED" | sed 's/^ //')"
    echo "Inferred: $INFERRED_TRIMMED" >&2
  fi
else
  echo "GREENFIELD"
fi
