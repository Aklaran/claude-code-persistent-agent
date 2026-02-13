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
for f in MEMORY.md TASKS.md; do
  if [ ! -f "$CLAUDE_DIR/memory/$f" ]; then
    cp "$SCRIPT_DIR/templates/$f" "$CLAUDE_DIR/memory/$f"
    echo "  Created ~/.claude/memory/$f (edit this!)"
  else
    echo "  Skipped ~/.claude/memory/$f (already exists)"
  fi
done

# On-demand context files (not loaded at startup)
for f in setup.md credentials.md; do
  if [ ! -f "$CLAUDE_DIR/$f" ]; then
    cp "$SCRIPT_DIR/templates/$f" "$CLAUDE_DIR/$f"
    echo "  Created ~/.claude/$f (edit this!)"
  else
    echo "  Skipped ~/.claude/$f (already exists)"
  fi
done

# Initialize reflections if missing
if [ ! -f "$CLAUDE_DIR/memory/reflections.jsonl" ]; then
  touch "$CLAUDE_DIR/memory/reflections.jsonl"
fi

# Install hooks
mkdir -p "$CLAUDE_DIR/hooks"
cp "$SCRIPT_DIR/claude/hooks/"*.sh "$CLAUDE_DIR/hooks/" 2>/dev/null
chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null

# Install TDD Guard custom instructions
mkdir -p "$CLAUDE_DIR/tdd-guard/data"
if [ ! -f "$CLAUDE_DIR/tdd-guard/data/instructions.md" ]; then
  cp "$SCRIPT_DIR/claude/tdd-guard/data/instructions.md" "$CLAUDE_DIR/tdd-guard/data/"
  echo "  Created TDD Guard custom instructions"
else
  echo "  Skipped TDD Guard instructions (already exists)"
fi

# Install bd-create
cp "$SCRIPT_DIR/bin/bd-create" "$CLAUDE_DIR/bin/"
chmod +x "$CLAUDE_DIR/bin/bd-create"

# Check for external tools
echo ""
echo "Checking optional tools..."

if command -v bd &>/dev/null; then
  echo "  ✓ bd (beads) found"
else
  echo "  ○ bd (beads) not found — go install github.com/codegangsta/beads/cmd/bd@latest"
fi

if command -v tdd-guard &>/dev/null; then
  echo "  ✓ tdd-guard found"
else
  echo "  ○ tdd-guard not found — npm install -g tdd-guard"
  echo "    Also install per-project reporter: pnpm add -D tdd-guard-vitest"
fi

if command -v recall &>/dev/null; then
  echo "  ✓ recall found"
else
  echo "  ○ recall not found — brew install zippoxer/tap/recall (or cargo install)"
fi

if command -v vestige-mcp &>/dev/null; then
  echo "  ✓ vestige-mcp found"
else
  echo "  ○ vestige-mcp not found — download from https://github.com/samvallad33/vestige/releases"
  echo "    Then: claude mcp add vestige vestige-mcp -s user"
fi

echo ""
echo "✅ Done! Next steps:"
echo "   1. Edit ~/.claude/memory/MEMORY.md — tell Claude who you are"
echo "   2. Edit ~/.claude/memory/TOOLS.md — document your infrastructure"
echo "   3. Install optional tools listed above (tdd-guard, recall, vestige)"
echo "   4. Start claude and say hello"
