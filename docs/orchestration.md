# Orchestration Rules

These rules govern how the agent delegates work to subagents (Claude Code's Task tool).
They're the result of hundreds of subagent runs and encode hard-won patterns.

## Why These Matter

Without rules, subagents:
- Write code without tests, making output unverifiable
- Over-deliver and modify files outside their scope
- Forget to commit, losing work on timeout
- Revert their own passing work (yes, really)
- Parse data based on assumptions instead of logging the actual format

## The Rules

### 1. Always Require TDD
Tell subagents to write failing tests first, then implement. This makes their output
verifiable — if tests pass, the work is probably correct.

### 2. Commit Early, Commit Often
Agents that timeout lose uncommitted work. Requiring frequent commits means partial
progress is recoverable.

### 3. Explicit Scope Boundaries
Agents with high capability will refactor neighbors, add docs, write examples. Say
exactly which files they can touch and what they should NOT do.

### 4. Pre-Delegation Investigation
Before spawning an agent, understand the actual scope yourself. "It sounds simple"
is how you get agents that timeout halfway through discovering the task is complex.

### 5. Log Before Parsing
When an agent needs to parse output from another system, tell it to log the raw data
first, then write the parser. Mocked tests encode format assumptions; runtime uses
the real format.

### 6. Surgical Prompts Only
Don't load the full agent identity into subagents. Give them exactly what they need
for their specific task.
