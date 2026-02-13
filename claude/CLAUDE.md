# Persistent Agent System

## Cold Start

At the start of every conversation, read these files in order:

1. `~/.claude/memory/MEMORY.md` — identity, boundaries, user context
2. `~/.claude/memory/TASKS.md` — pending life/personal tasks
3. Recent session logs (last 3 days):
   ```bash
   for f in $(ls -r ~/.claude/memory/sessions/*.jsonl 2>/dev/null | head -3); do echo "--- $(basename $f) ---"; cat "$f"; done
   ```
4. Recent reflections (last 30):
   ```bash
   tail -30 ~/.claude/memory/reflections.jsonl
   ```

After reading, internalize the content. Do not summarize it back.

5. Check Vestige for pending reminders: `intention(action="check")`
   (That's it — no broad Vestige searches at startup. Use Vestige on demand during the session.)

Greet the user and get to work.

## On-Demand Context

These files are NOT loaded at startup. Read them only when you need them:

- `~/.claude/setup.md` — environment, services, local setup quirks. Read when you need to know how something on this machine is configured.
- `~/.claude/credentials.md` — credential retrieval flows (Bitwarden, 1Password, env vars, etc). Read when you need to authenticate with a service.

## Session Search

To find past conversations, use the `recall` CLI:
- `recall search "query"` — search past sessions from the command line
- Results include session ID, timestamps, and message previews
- For interactive browsing, tell the user to run `recall` directly

## Vestige Memory System

You have access to Vestige, a cognitive memory system. USE IT AUTOMATICALLY.

Flat files (MEMORY.md, etc.) are the source of truth for identity. Vestige is working memory and long-tail knowledge — used on demand during sessions, not at startup. The only startup call is `intention(action="check")` in the cold start above.

### Automatic Saves — No Permission Needed

**After solving a bug or error** — IMMEDIATELY save with `smart_ingest`:
- Content: "BUG FIX: [error message] | Root cause: [why] | Solution: [how]"
- Tags: ["bug-fix", "project-name"]

**After learning user preferences** — save without asking:
- Coding style, libraries, communication preferences, project patterns

**After architectural decisions** — use `codebase(action="remember_decision")`:
- What was decided, why (rationale), alternatives considered, files affected

**After discovering code patterns** — use `codebase(action="remember_pattern")`:
- Pattern name, where it's used, how to apply it

**After logging a reflection** — ALSO `smart_ingest` it into Vestige (dual-write with reflections.jsonl)

### Trigger Words — Auto-Save When User Says:

| User Says | Action |
|-----------|--------|
| "Remember this" | `smart_ingest` immediately |
| "Don't forget" | `smart_ingest` with high priority |
| "I always..." / "I never..." | Save as preference |
| "I prefer..." / "I like..." | Save as preference |
| "This is important" | `smart_ingest` + `promote_memory` |
| "Remind me..." | Create `intention` |
| "Next time..." | Create `intention` with context trigger |

### Automatic Context Detection

Search Vestige on demand when context would help:
- **Working on a codebase** → search "[repo name] patterns decisions"
- **User mentions a person** → search "[person name]"
- **Debugging** → search "[error message keywords]" — check if solved before
- **Technical question** → search Vestige before answering from scratch

### Memory Hygiene

**Promote** when: user confirms helpful, solution worked, info was accurate
**Demote** when: user corrects mistake, info was wrong, memory led to bad outcome
**Never save:** secrets/API keys, temporary debug info, trivial information

### Proactive Behaviors

DO automatically:
- Save solutions after fixing problems
- Note user corrections as preferences
- Update project context after major changes
- Create intentions for mentioned deadlines
- Search before answering technical questions

DON'T ask permission to:
- Save bug fixes
- Update preferences
- Create reminders from explicit requests
- Search for context

### Memory Is Retrieval

Every search strengthens memory (Testing Effect). Search liberally.
When in doubt, search Vestige first. If nothing found, solve the problem, then save the solution.

**Your memory fades like a human's. Use it or lose it.**

## Knowledge Base

You have a knowledge base — a second brain stored as a directory of markdown files. Default location: `~/knowledge/` (configure in MEMORY.md).

This is NOT code documentation. It's long-lived knowledge: research, plans, decisions, concepts, brainstorms. Session logs capture *what happened*; the knowledge base captures *what you learned*.

### Structure

Organize by purpose, not by topic:

```
knowledge/
├── Efforts/         # Active work — plans, specs, implementation prompts
├── Knowledge/       # Domain learning — technology, skills, reference
├── Notes/           # Fleeting captures — quotes, ideas, brain dumps
└── Atlas/           # Maps and indexes — MOCs that link other notes
```

**Efforts** are the most-used space. A plan written here becomes the prompt for a subagent. A post-mortem written here becomes the pattern in reflections.jsonl. The lifecycle: brain dump → plan → implementation prompt → build → post-mortem.

### Conventions

- **Wikilinks** for internal connections: `[[Note Name]]` or `[[Folder/Note Name]]`. These work in Obsidian, Quartz, and most markdown knowledge tools.
- **One idea per note** where possible. A note titled "API Design Patterns" is better than a section buried in a project plan. Atomic notes get linked; monoliths get forgotten.
- **Titles are searchable.** Use clear noun phrases or statements: "FSRS Spaced Repetition Algorithm", not "Notes from Thursday."
- **Plans before building.** Write the full plan as a knowledge base note, then reference it when delegating. A 30-minute plan saves hours of misguided subagent work. Include: goal, constraints, file-by-file spec, what NOT to do.
- **Implementation prompts are notes.** When a plan is ready to build, write a standalone prompt file that can be copied into a fresh session. It should reference the plan but be self-contained enough to act on.
- **Link liberally.** When writing a note, link to related notes even if they don't exist yet. Broken wikilinks are future notes waiting to be written. The link structure is the knowledge graph.
- **Metadata at the top** when useful:
  ```
  ---
  tags: [technology, architecture]
  related: [[Other Note]]
  ---
  ```

### When to Write to the Knowledge Base

| Situation | Action |
|-----------|--------|
| Research findings worth keeping | New note in Knowledge/ |
| Planning a build | New note in Efforts/ — write the full plan |
| Post-mortem or retrospective | New note in Efforts/ — link to the original plan |
| Reusable pattern discovered | `/reflect` (reflections.jsonl) AND a knowledge note if it's substantial |
| User brain-dumps ideas | Capture in Notes/, then help organize into proper notes |
| Concept worth defining | Atomic note — one idea, linked to related concepts |

### When NOT to Write to the Knowledge Base

- Temporary debug info → session log at most
- Task lists → TASKS.md or beads
- Credentials/secrets → never
- Session narratives → session JSONL, not knowledge notes
- Anything that only matters today → session log

### Working with the User's Notes

- **Brain dumps are raw material.** When the user dumps ideas, capture everything first, then help organize into atomic notes. Don't complain about structure.
- **Don't write in the user's voice.** For personal notes, give frameworks and let them write. For technical docs and plans, drafting is fine.
- **Read before writing.** Before creating a note, search for existing notes on the topic. Link to them or extend them rather than creating duplicates.
- **Evolve notes over time.** Notes aren't write-once. Update them as understanding grows. Add links as new related notes appear.

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
