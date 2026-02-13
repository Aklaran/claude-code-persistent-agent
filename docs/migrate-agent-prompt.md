# Agent Migration Prompt

*Give this prompt to your existing agent to migrate itself into the persistent agent system. Copy the whole thing into a session.*

---

You are migrating your persistent memory system into a new structure. The target system lives at https://github.com/Aklaran/claude-code-persistent-agent. Do NOT run install.sh — you're going to migrate manually to preserve your existing data.

## Step 1: Clone the repo

```bash
git clone https://github.com/Aklaran/claude-code-persistent-agent.git ~/repos/claude-persistent-agent
```

## Step 2: Inventory your current system

Before changing anything, find and report:
1. Where is your CLAUDE.md? (`~/.claude/CLAUDE.md`, project-level, or elsewhere?)
2. Where are your memory/identity files? What are they called?
3. Where are your session logs? What format? (JSONL, markdown, other?)
4. Do you have a reflections or patterns file? Where?
5. Do you have a knowledge base / vault / notes directory? Where?
6. What's in your current `~/.claude/settings.json`? (especially hooks)
7. What MCP servers are registered? (`claude mcp list` if available)

Report all of this before proceeding. Do not guess — read the actual files.

## Step 3: Create the directory structure

```bash
mkdir -p ~/.claude/memory/sessions
mkdir -p ~/.claude/templates/tdd-guard
```

## Step 4: Migrate memory files

The system expects `~/.claude/memory/MEMORY.md` as the core identity file.

- If you have an existing identity/memory file, copy it:
  ```bash
  cp /path/to/your/memory-file ~/.claude/memory/MEMORY.md
  ```
- If your identity is spread across multiple files, consolidate into one MEMORY.md. It should contain: who the user is, boundaries, active projects, working patterns.
- Do NOT use the template from the repo — your existing data is more valuable.

## Step 5: Migrate session logs

The system uses `~/.claude/memory/sessions/YYYY-MM-DD.jsonl`. Each line is one JSON object:
```json
{"date":"YYYY-MM-DD","session":"Title","time":"HH:MM","summary":"...","decisions":["..."],"artifacts":["..."],"open_threads":["..."]}
```

- If your logs are already JSONL, copy them into `~/.claude/memory/sessions/`
- If your logs are in a different format, convert them. Write a small script to transform each entry into the JSONL format above. Preserve the dates, summaries, and any decision/artifact data.
- If conversion is impractical, leave old logs in place and start fresh — only new sessions will use the new format. Old sessions are searchable via `recall`.

## Step 6: Migrate reflections

The system uses `~/.claude/memory/reflections.jsonl`. Each line:
```json
{"type":"pattern","content":"Description of the pattern."}
```
Types: `pattern`, `reflection`, `idea`.

- If you have a reflections file, copy or convert it
- If your patterns live inside your memory file or elsewhere, extract them into this format
- If nothing to migrate, create an empty file: `touch ~/.claude/memory/reflections.jsonl`

## Step 7: Knowledge base

The system expects a knowledge base directory. Default is `~/knowledge/` but any path works.

- If you already have a vault, notes directory, or docs folder — keep it where it is
- Add the path to your MEMORY.md:
  ```markdown
  ## Knowledge Base
  - Location: ~/path/to/your/vault/
  ```
- Do NOT move or restructure your existing notes

## Step 8: Install on-demand files

These are new files that the agent reads only when needed (not at startup):

```bash
cp ~/repos/claude-persistent-agent/templates/setup.md ~/.claude/setup.md
cp ~/repos/claude-persistent-agent/templates/credentials.md ~/.claude/credentials.md
```

If you already have infrastructure docs or credential flows documented, move that content into these files. Otherwise fill them in later.

## Step 9: Install templates

```bash
cp ~/repos/claude-persistent-agent/templates/tdd-guard/instructions.md ~/.claude/templates/tdd-guard/
```

## Step 10: Install the /review command

```bash
mkdir -p ~/.claude/commands
cp ~/repos/claude-persistent-agent/claude/commands/review.md ~/.claude/commands/
```

## Step 11: Merge CLAUDE.md

This is the most important step. Read the new CLAUDE.md:
```bash
cat ~/repos/claude-persistent-agent/claude/CLAUDE.md
```

Now read your existing CLAUDE.md (if you have one):
```bash
cat ~/.claude/CLAUDE.md
```

Merge them. The new CLAUDE.md has these sections:
- **Cold Start** — reads memory files at conversation start
- **On-Demand Context** — setup.md and credentials.md
- **Session Search** — recall CLI
- **Vestige Memory System** — cognitive memory protocol
- **Knowledge Base** — shared notes conventions
- **Subagent Orchestration** — delegation rules
- **Working Patterns** — TDD, commit discipline, etc.
- **Session Logging** — JSONL format

Rules for merging:
- Keep any custom rules or patterns from your existing CLAUDE.md
- At minimum, include the **Cold Start** section pointing to your migrated files
- The orchestration rules and working patterns are battle-tested — adopt unless you have your own equivalents
- If your existing file has identity/personality instructions, those belong in MEMORY.md, not CLAUDE.md

Write the merged result to `~/.claude/CLAUDE.md`.

## Step 12: Merge settings.json

Read the new settings.json:
```bash
cat ~/repos/claude-persistent-agent/claude/settings.json
```

Read your existing settings.json:
```bash
cat ~/.claude/settings.json 2>/dev/null || echo "No existing settings.json"
```

If you have existing hooks, merge the TDD Guard hooks into your file — don't replace it. If you have no settings.json, copy the new one:
```bash
cp ~/repos/claude-persistent-agent/claude/settings.json ~/.claude/settings.json
```

## Step 13: Install bd-create

```bash
mkdir -p ~/.claude/bin
cp ~/repos/claude-persistent-agent/bin/bd-create ~/.claude/bin/
chmod +x ~/.claude/bin/bd-create
```

## Step 14: Verify

Report:
1. What files exist in `~/.claude/memory/`?
2. What does `~/.claude/CLAUDE.md` contain? (section headers only)
3. What hooks are in `~/.claude/settings.json`?
4. Where is the knowledge base pointed?
5. Were any files lost or skipped during migration?

## What NOT to do

- Do NOT delete your original files until you've verified the migration
- Do NOT run install.sh — it would overwrite your carefully merged CLAUDE.md
- Do NOT install external tools (Vestige, recall, tdd-guard) in this session — just set up the file structure
- Do NOT create a knowledge base from scratch if one already exists
