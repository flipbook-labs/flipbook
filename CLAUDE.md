@AGENTS.md

# Claude-specific routing

Follow [`AGENTS.md`](AGENTS.md) first — its "Shared skills" section is the gate: run `lute run install`, resolve the `~/.loom/store/AgentSkills@*` path, and read that library's routing index before any code, tests, or PR prose.

The shared skills live under `<skills>/src/<scope>/<name>/SKILL.md` (the path you resolve in that section), not in `.claude/skills/`, so the Skill tool does not surface them. Route to them yourself by following the gate in AGENTS.md.
