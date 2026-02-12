#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Setting up persistent Claude Code agent..."

# Create directory structure
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/memory/sessions"
mkdir -p "$CLAUDE_DIR/bin"

# Install CLAUDE.md (backup existing)
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  echo "⚠️  Existing CLAUDE.md found. Backing up to CLAUDE.md.bak"
  cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"
fi
cp "$SCRIPT_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# Install settings.json (backup existing)
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo "⚠️  Existing settings.json found. Backing up to settings.json.bak"
  cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
fi
cp "$SCRIPT_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"

# Install commands
cp "$SCRIPT_DIR/claude/commands/"*.md "$CLAUDE_DIR/commands/"

# Copy templates (never overwrite existing memory files)
for f in MEMORY.md TOOLS.md TASKS.md; do
  if [ ! -f "$CLAUDE_DIR/memory/$f" ]; then
    cp "$SCRIPT_DIR/templates/$f" "$CLAUDE_DIR/memory/$f"
    echo "  Created ~/.claude/memory/$f (edit this!)"
  else
    echo "  Skipped ~/.claude/memory/$f (already exists)"
  fi
done

# Initialize reflections if missing
if [ ! -f "$CLAUDE_DIR/memory/reflections.jsonl" ]; then
  touch "$CLAUDE_DIR/memory/reflections.jsonl"
fi

# Install bd-create
cp "$SCRIPT_DIR/bin/bd-create" "$CLAUDE_DIR/bin/"
chmod +x "$CLAUDE_DIR/bin/bd-create"

# Check for bd
if command -v bd &>/dev/null; then
  echo "  ✓ bd (beads) found"
else
  echo "  ⚠️  bd (beads) not found."
  echo "     Install: go install github.com/codegangsta/beads/cmd/bd@latest"
  echo "     Or remove beads references from CLAUDE.md if you don't want task tracking."
fi

echo ""
echo "✅ Done! Next steps:"
echo "   1. Edit ~/.claude/memory/MEMORY.md — tell Claude who you are"
echo "   2. Edit ~/.claude/memory/TOOLS.md — document your infrastructure"
echo "   3. Start claude and say hello"
