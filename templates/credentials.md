# Credentials — How to Authenticate

*Credential retrieval flows. Read by the agent on demand when it needs to authenticate.*

---

## How I Store Credentials

[Describe your approach: Bitwarden CLI, 1Password CLI, `pass`, env vars, etc.]

## [Service Name]

- **Credential location:** [e.g., "Bitwarden vault under 'GitHub'"]
- **Retrieval:**
  ```bash
  # Example: Bitwarden CLI
  bw get password "GitHub"
  ```

---

**Rules:**
- NEVER paste raw secrets, API keys, or tokens into this file
- Store *flows* (how to retrieve), not *values*
- Agent should retrieve credentials at runtime, not cache them

*Update as services change.*
