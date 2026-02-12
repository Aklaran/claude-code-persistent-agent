Summarize this conversation and append to today's session log.

File: ~/.claude/memory/sessions/$(date +%Y-%m-%d).jsonl

Create the file if it doesn't exist. Append one JSON line:
{"date":"YYYY-MM-DD","session":"<title>","time":"HH:MM","summary":"<compressed narrative>","decisions":["<why not just what>"],"artifacts":["<files, commits, beads>"],"open_threads":["<what's unfinished>"]}

Rules:
- Compress. No blow-by-blow.
- Decisions should explain WHY, not just WHAT.
- If nothing meaningful happened, say so and don't write.
