# Migrating from an Existing Setup

If you already have a persistent agent system — memory files, session logs,
a knowledge base, custom CLAUDE.md — this guide helps you integrate without
losing data.

## Before You Start

**Don't run `install.sh` blindly.** It backs up your existing CLAUDE.md and
settings.json, but a backup isn't a migration plan. Read this first.

Take stock of what you have:

- [ ] A CLAUDE.md or system prompt? Where?
- [ ] Memory/identity files? What format, what location?
- [ ] Session logs? What format (JSONL, markdown, plain text)?
- [ ] Reflections or patterns file?
- [ ] A knowledge base or vault? Where?
- [ ] Custom hooks in settings.json?
- [ ] MCP servers already registered?

## Step-by-Step

### 1. Memory Files

The system expects `~/.claude/memory/MEMORY.md`. If you already have an
identity/memory file:

```bash
# Copy your existing file — don't use the template
cp /path/to/your/memory.md ~/.claude/memory/MEMORY.md
```

If your memory is split across multiple files, consolidate into MEMORY.md.
It should contain: who you are, who the user is, boundaries, active projects,
working patterns. See `templates/MEMORY.md` for the structure.

### 2. Session Logs

The system uses JSONL files at `~/.claude/memory/sessions/YYYY-MM-DD.jsonl`.
Each line is one JSON object:

```json
{"date":"2026-02-08","session":"Title","time":"14:05","summary":"What happened.","decisions":["Why we chose X"],"artifacts":["files/created"],"open_threads":["What's unfinished"]}
```

**If your logs are already JSONL in a different location:**
```bash
mkdir -p ~/.claude/memory/sessions
cp /path/to/your/sessions/*.jsonl ~/.claude/memory/sessions/
```

**If your logs are in a different format (markdown, plain text):**
You have two options:
1. Convert them to JSONL (write a script or ask the agent to help)
2. Leave them where they are and use `recall` to search them — only new
   sessions will use the JSONL format going forward

Don't stress about converting old logs. The last 3 days are what matter
at startup. Older history is searchable via `recall`.

### 3. Reflections

The system uses `~/.claude/memory/reflections.jsonl`. Each line:

```json
{"type":"pattern","content":"Description of the pattern."}
```

Types: `pattern`, `reflection`, `idea`.

**If you have an existing reflections/patterns file:**
```bash
cp /path/to/your/reflections.jsonl ~/.claude/memory/reflections.jsonl
```

**If your patterns are in a different format:**
Convert, or start fresh — your existing patterns are likely captured in
your memory file or session logs already. The last 30 entries are loaded
at startup.

### 4. Knowledge Base

The system expects a knowledge base directory (default `~/knowledge/`).
Set the actual path in your MEMORY.md.

**If you have an Obsidian vault, a docs folder, or any markdown directory:**
Just point to it. Add to your MEMORY.md:

```markdown
## Knowledge Base
- Location: ~/path/to/your/vault/
```

No need to move or restructure anything. The conventions in CLAUDE.md
(wikilinks, atomic notes, Efforts/ structure) are recommendations, not
requirements. Your existing structure works fine.

### 5. CLAUDE.md

This is the hardest part. The system's CLAUDE.md contains:
- Cold start sequence
- Vestige memory protocol
- Knowledge base conventions
- Orchestration rules
- Working patterns
- Session logging format

**If you have an existing CLAUDE.md:**

Don't replace it wholesale. Instead:

1. Read through both files
2. Merge sections that matter to you into your existing CLAUDE.md
3. At minimum, add the **Cold Start** section (so the agent reads your files)
4. The orchestration rules and working patterns are optional but battle-tested

Or, start from the provided CLAUDE.md and port your custom rules into it.

**The install script will back up your existing file to `CLAUDE.md.bak`.**

### 6. settings.json (Hooks)

The system ships TDD Guard hooks. If you have existing hooks:

```bash
# Check what you have
cat ~/.claude/settings.json
```

**If you have no hooks:** The install script will copy settings.json cleanly.

**If you have existing hooks:** Don't let the install script overwrite.
Instead, manually merge the TDD Guard hooks into your existing file:

```json
{
  "hooks": {
    "PreToolUse": [
      // ... your existing hooks ...
      {
        "matcher": "Write|Edit|MultiEdit|TodoWrite",
        "hooks": [{ "type": "command", "command": "tdd-guard" }]
      }
    ]
  }
}
```

### 7. On-Demand Files

Create these if you don't have equivalents:

```bash
cp templates/setup.md ~/.claude/setup.md
cp templates/credentials.md ~/.claude/credentials.md
```

If you already have infrastructure docs or credential flows documented
somewhere, either move them into these files or update CLAUDE.md to
point to your existing locations.

### 8. External Tools

These are all optional. Install what you want:

- **Vestige** — `claude mcp add vestige vestige-mcp -s user` (after installing the binary)
- **recall** — `brew install zippoxer/tap/recall` or `cargo install`
- **TDD Guard** — `npm install -g tdd-guard` (plus per-project test reporter)
- **Beads** — `go install github.com/codegangsta/beads/cmd/bd@latest`

If you don't install Vestige, the system still works — flat files handle
everything. The CLAUDE.md instructions for Vestige will just go unused.

## After Migration

1. Start a new Claude Code session
2. Verify the agent reads your memory files at startup
3. Check that your identity, projects, and context came through
4. Try a `/review` if you use the tmux+neovim workflow
5. Log a session at the end to confirm the JSONL path works

## Common Issues

**Agent doesn't read my files at startup:**
Check that CLAUDE.md is at `~/.claude/CLAUDE.md` (global) and contains
the Cold Start section.

**Lost my existing hooks after install:**
Restore from `~/.claude/settings.json.bak` and merge manually.

**Session logs in wrong format:**
Old logs stay as-is. New sessions will use the correct JSONL format.
Use `recall` to search everything regardless of format.
