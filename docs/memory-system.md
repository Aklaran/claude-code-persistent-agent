# Memory System

The persistent agent uses a simple file-based memory system. No databases, no
vector stores — just files that Claude reads at the start of each conversation.

## Files

### Loaded at Startup

| File | Purpose | Updated by |
|------|---------|------------|
| MEMORY.md | Identity, boundaries, user context | You (manually) |
| sessions/YYYY-MM-DD.jsonl | Daily session logs (last 3 days loaded) | Agent (/log-session) |
| reflections.jsonl | Patterns and lessons (last 30 loaded) | Agent (/reflect) |

### Loaded On Demand

| File | Purpose | When |
|------|---------|------|
| ~/.claude/setup.md | Environment, services, local quirks | When the agent needs to know how something is configured |
| ~/.claude/credentials.md | Credential retrieval flows | When the agent needs to authenticate with a service |

## How It Works

1. CLAUDE.md tells Claude to read the memory files at conversation start
2. Claude internalizes the content and knows who you are, what you're working on
3. When the agent needs environment or credential info, it reads the on-demand files
4. At session end, /log-session captures what happened
5. /reflect captures reusable patterns across sessions
6. Next session, Claude reads the new logs and picks up where you left off

## Session Log Format

One JSON line per session in `sessions/YYYY-MM-DD.jsonl`:

{"date":"2026-02-08","session":"Title","time":"14:05","summary":"What happened.","decisions":["Why we chose X"],"artifacts":["files/created"],"open_threads":["What's unfinished"]}

## Reflections Format

One JSON line per insight in `reflections.jsonl`:

{"type":"pattern","content":"Description of the pattern and when it applies."}

Types: pattern (reusable rule), reflection (one-time insight), idea (future possibility).

## Knowledge Base

Beyond session memory, the system supports a long-lived knowledge base — a directory
of markdown files for research, plans, decisions, and concepts. Default: `~/knowledge/`.

This is your second brain. Session logs capture *what happened*; the knowledge base
captures *what you learned*.

### Structure

```
knowledge/
├── Efforts/         # Plans, specs, implementation prompts, post-mortems
├── Knowledge/       # Domain learning, reference material
├── Notes/           # Fleeting captures, brain dumps
└── Atlas/           # Maps of Content — index notes that link others
```

### Key Conventions

- **Wikilinks** (`[[Note Name]]`) for internal connections
- **Atomic notes** — one idea per note, linked to related concepts
- **Plans before building** — write the full plan as a note, then delegate from it
- **Implementation prompts** — standalone files that can seed a fresh session
- **Evolve over time** — notes aren't write-once; update and link as understanding grows

See the "Knowledge Base" section in CLAUDE.md for the full protocol.
