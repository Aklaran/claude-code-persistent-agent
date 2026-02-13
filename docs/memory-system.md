# Memory System

The persistent agent uses a layered memory system: flat files for identity and
session history, Vestige for long-tail knowledge, and a shared knowledge base
for collaborative notes.

## Layers

### 1. Flat Files (Always Available)

Loaded at startup. No dependencies, no servers — just files.

| File | Purpose | Updated by |
|------|---------|------------|
| `~/.claude/memory/MEMORY.md` | Identity, boundaries, user context | You (manually) |
| `~/.claude/memory/sessions/*.jsonl` | Daily session logs (last 3 days loaded) | Agent |
| `~/.claude/memory/reflections.jsonl` | Patterns and lessons (last 30 loaded) | Agent |

### 2. On-Demand Files

NOT loaded at startup. The agent reads these only when it needs them.

| File | Purpose | When |
|------|---------|------|
| `~/.claude/setup.md` | Environment, services, local quirks | Agent needs to know how something is configured |
| `~/.claude/credentials.md` | Credential retrieval flows | Agent needs to authenticate with a service |

### 3. Vestige (Cognitive Memory)

MCP server with semantic search, spaced repetition decay, and spreading
activation. Optional but recommended.

- **At startup:** one `intention(action="check")` call for pending reminders
- **During sessions:** auto-saves bug fixes, preferences, decisions, patterns
- **On demand:** semantic search when context would help (debugging, codebase work, etc.)
- **Reflections:** saved to `reflections.jsonl` (source of truth) and also ingested to Vestige when available

Vestige is working memory. If it's not installed or its DB is lost, flat files
still have everything essential.

### 4. recall (Session Search)

Standalone CLI that searches raw Claude Code session files. Complements curated
session logs — recall is "grep for conversations," session JSONL is "what mattered."

### 5. Knowledge Base (Shared)

A directory of markdown files (`~/knowledge/` by default) where you and the agent
collaborate on plans, research, and long-lived knowledge.

This exists for *your* benefit — the agent's own recall lives in Vestige and session
logs. The knowledge base is where you build understanding together.

See the "Knowledge Base" section in CLAUDE.md for conventions and workflows.

## Cold Start Flow

1. Read `MEMORY.md` — agent knows who you are
2. Read last 3 days of session logs — agent has recent context
3. Read last 30 reflections — agent knows patterns and lessons
4. Check Vestige intentions — catch reminders from past sessions
5. Greet user, get to work

No broad searches at startup. Vestige and recall are used on demand during sessions.

## Session Log Format

One JSON line per session in `sessions/YYYY-MM-DD.jsonl`:

```json
{"date":"2026-02-08","session":"Title","time":"14:05","summary":"What happened.","decisions":["Why we chose X"],"artifacts":["files/created"],"open_threads":["What's unfinished"]}
```

Rules:
- One compressed summary, not blow-by-blow
- Decisions explain WHY, not just WHAT
- If nothing meaningful happened, don't log

## Reflections Format

One JSON line per insight in `reflections.jsonl`:

```json
{"type":"pattern","content":"Description of the pattern and when it applies."}
```

Types: `pattern` (reusable rule), `reflection` (one-time insight), `idea` (future possibility).

Last 30 are loaded at startup. Full file searchable via grep. Also ingested
to Vestige when available for semantic search and natural decay of stale patterns.

## How the Layers Relate

| Need | Source |
|------|--------|
| Who is the user? | MEMORY.md |
| What happened recently? | Session logs (last 3 days) |
| What patterns have we learned? | reflections.jsonl (last 30) + Vestige |
| What was that conversation about X? | recall |
| How did we fix that bug before? | Vestige search |
| What's the plan for this project? | Knowledge base |
| How is this machine configured? | setup.md (on demand) |
| How do I authenticate with Y? | credentials.md (on demand) |
