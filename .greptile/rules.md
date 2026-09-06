# Review context

Treat `AGENTS.md`, `.github/MERGE_POLICY.md`, and the relevant vendored skills under `.agents/skills` as authoritative repository guidance. Use `flipbook-labs/agent-skills` for shared organization conventions and Storyteller and ModuleLoader for cross-repository implementation context.

Keep `files.json` limited to stable initial context. Do not add every specialized skill or reference document to it; follow the skill index and the changed code into deeper context when relevant.

When sources conflict, prefer this repository and then its vendored skills. Assess implementation safety independently from merge authorization: a change requiring human application approval is not inherently lower quality.
