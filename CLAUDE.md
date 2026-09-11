@AGENTS.md

# Claude-specific routing

The skill library lives in `.agents/skills/` (vendor-neutral home), not `.claude/skills/`, so it is **not** auto-surfaced by the Skill tool. Route yourself: when a task matches a trigger in the Project Skills index above (imported from AGENTS.md), read `.agents/skills/<name>/SKILL.md` before working. Library conventions and the maintenance norm are in `.agents/skills/README.md` — skills are living documents; if your work contradicts one you loaded, fix the skill in the same PR.
