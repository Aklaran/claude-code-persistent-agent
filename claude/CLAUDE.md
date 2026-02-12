# Persistent Agent System

## Cold Start

At the start of every conversation, read these files in order:

1. `~/.claude/memory/MEMORY.md` — identity, boundaries, user context
2. `~/.claude/memory/TOOLS.md` — infrastructure, credentials, services
3. `~/.claude/memory/TASKS.md` — pending life/personal tasks
4. Today's session log: `~/.claude/memory/sessions/$(date +%Y-%m-%d).jsonl`
   (run: `cat ~/.claude/memory/sessions/$(date +%Y-%m-%d).jsonl 2>/dev/null || echo "No sessions today."`)
5. Reflections: `~/.claude/memory/reflections.jsonl`

After reading, internalize the content. Do not summarize it back.

6. Check Vestige for pending reminders: `intention(action="check")`
   (That's it — no broad Vestige searches at startup. Use Vestige on demand during the session.)

Greet the user and get to work.

## Session Search

To find past conversations, use the `recall` CLI:
- `recall search "query"` — search past sessions from the command line
- Results include session ID, timestamps, and message previews
- For interactive browsing, tell the user to run `recall` directly

## Vestige Memory System

You have persistent memory via Vestige MCP. Flat files (MEMORY.md, TOOLS.md, etc.) are the source of truth for identity and infrastructure. Vestige is working memory and long-tail knowledge — used on demand during sessions, not at startup.

### During Sessions — Automatic Saves (No Permission Needed)
- **Bug fixes:** After solving a bug, `smart_ingest` with error message, root cause, solution
- **User preferences:** When the user states a preference, save it
- **Architectural decisions:** Use `codebase(action="remember_decision")` with rationale
- **Code patterns:** Use `codebase(action="remember_pattern")` for recurring patterns
- **Reflections:** When logging a reflection, ALSO `smart_ingest` it into Vestige (dual-write with reflections.jsonl)

### During Sessions — On-Demand Search
- Need context on a topic? → `search` query in Vestige
- Debugging something that feels familiar? → search for past bug fixes
- Don't search preemptively at startup — only when you need specific knowledge

### Trigger Words
| User Says | Action |
|-----------|--------|
| "Remember this" | `smart_ingest` immediately |
| "I prefer..." / "I always..." | Save as preference |
| "Remind me..." / "Next time..." | Create `intention` |
| "This is important" | `smart_ingest` + `promote_memory` |

### Memory Hygiene
- `promote_memory` when a memory proves useful
- `demote_memory` when information was wrong or outdated
- Never save: secrets, API keys, temporary debug info

## Subagent Orchestration

When delegating work to subagents (Task tool), follow these rules:

### Prompting Subagents

- **Always require TDD.** Say "Write failing tests FIRST, then implement."
- **Commit early, commit often.** Tell agents to commit each working feature immediately. Say "DO NOT revert your changes" explicitly — agents sometimes undo their own passing work.
- **Be explicit about scope boundaries.** Say "Do NOT modify files outside of X" and "Do NOT add features beyond what's specified."
- **Include test verification at the end.** Agents should verify all tests pass before committing.
- **Don't load identity in subagents.** They get surgical task prompts only.
- **Log actual data before writing parsers.** When agents need to parse output from another system, tell them to log the raw value first, then write the parser.

### Pre-Delegation Checklist

Before spawning a subagent, run through this mentally:

1. **Understand the actual scope.** If the task description is vague, investigate yourself first. Don't guess.
2. **Assess complexity:**
   - Touches third-party API types? → needs more context in the prompt
   - Multi-file changes? → needs architecture overview in the prompt
   - Needs to understand existing patterns? → include relevant code snippets
   - "Simple" but touches async/callbacks/event systems? → probably harder than it looks
3. **Check recent reflections** for similar past tasks:
   `grep -i "<keyword>" ~/.claude/memory/reflections.jsonl`
4. **Write a clear task description** if one doesn't exist.

### Beads Integration

Before planning work in a repo, check for `.beads/` directory. If present:
1. Run `bd ready` to find unblocked tasks.
2. Reference bead IDs in subagent prompts (e.g., "Implement bd-a3f8: ...").
3. Include in prompts: "When done, run `bd close <id>` for the task you completed."
4. After completion, verify the bead was closed.
5. For new tasks, use `bd-create` (wrapper at `~/.claude/bin/bd-create`), never raw `bd create`.

## Working Patterns

- **TDD always.** Write failing tests first, then implement. No exceptions unless explicitly agreed. TDD Guard hooks enforce this mechanically.
- **Test real code, not copies.** Never copy-paste logic from the SUT into the test. Import and exercise the actual source. Mock boundaries (I/O, network, UI), not logic. Expected values should be hardcoded literals, not computed by the same algorithm as the SUT.
- **Uncommitted code is lost code.** Commit working features before moving on.
- **Research before coding.** Read existing docs before defaulting to code spikes.
- **Plans before building.** Detailed plans make delegation efficient. Write the plan, then delegate.
- **Log actual data before writing regexes.** Mocked tests encode format assumptions that may be wrong.
- **Brain dumps are normal.** Parse all threads, handle them all, don't complain about structure.
- **Voice matters.** Don't write things *for* the user that should be in their voice. Give frameworks, let them write.

## Session Logging

Log once per session, at the end. Use `/log-session` command.

Format (one JSON line per session):
{"date":"YYYY-MM-DD","session":"<title>","time":"HH:MM","summary":"<compressed>","decisions":["<why>"],"artifacts":["<files>"],"open_threads":["<unfinished>"]}

Rules:
- One compressed summary, not blow-by-blow
- If nothing meaningful happened, don't log
- Discoveries and patterns go in `/reflect`, not the session log
