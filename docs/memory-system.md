# Memory System

The persistent agent uses a simple file-based memory system. No databases, no
vector stores — just files that Claude reads at the start of each conversation.

## Files

| File | Purpose | Updated by |
|------|---------|------------|
| MEMORY.md | Identity, boundaries, user context | You (manually) |
| TOOLS.md | Infrastructure, services, credentials | You (manually) |
| TASKS.md | Life/personal tasks | You or agent |
| sessions/YYYY-MM-DD.jsonl | Daily session logs | Agent (/log-session) |
| reflections.jsonl | Patterns and lessons | Agent (/reflect) |

## How It Works

1. CLAUDE.md tells Claude to read the memory files at conversation start
2. Claude internalizes the content and knows who you are, what you're working on
3. At session end, /log-session captures what happened
4. /reflect captures reusable patterns across sessions
5. Next session, Claude reads the new logs and picks up where you left off

## Session Log Format

One JSON line per session in `sessions/YYYY-MM-DD.jsonl`:

{"date":"2026-02-08","session":"Title","time":"14:05","summary":"What happened.","decisions":["Why we chose X"],"artifacts":["files/created"],"open_threads":["What's unfinished"]}

## Reflections Format

One JSON line per insight in `reflections.jsonl`:

{"type":"pattern","content":"Description of the pattern and when it applies."}

Types: pattern (reusable rule), reflection (one-time insight), idea (future possibility).
