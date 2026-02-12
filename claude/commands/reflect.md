Append a reflection, pattern, or idea to the reflections file.

Ask me: what type? (pattern | reflection | idea)
Ask me: what's the content?

Then append exactly one JSON line to `~/.claude/memory/reflections.jsonl`:
{"type":"$TYPE","content":"$CONTENT"}

Do not rewrite the file. Append only. Use bash:
echo '{"type":"...","content":"..."}' >> ~/.claude/memory/reflections.jsonl
