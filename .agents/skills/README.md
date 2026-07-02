# Flipbook skill library — conventions

These skills exist to give an agent production-grade context on Flipbook without loading everything into always-on context. They are **living documents**, not a frozen spec. This file governs how to trust them and how to keep them from drifting. Read it before authoring or heavily editing a skill.

The library lives in `.agents/skills/` (vendor-neutral, per the AGENTS.md convention) rather than a tool-specific directory. Routing is manual: the **Project Skills index in AGENTS.md** maps triggers to skills, and agents are expected to read the matching `SKILL.md` before working. That index is part of the library — **adding, renaming, or retiring a skill requires updating the index in the same commit**, or the skill silently stops being loaded.

## Two genres: process and knowledge

Every skill declares `type: process` or `type: knowledge` in its frontmatter. Both genres load the same way (trigger description → read on demand); the split governs *form* and *how they rot*, not where they live:

- **Process** (`type: process`) — imperative, "do this next": runbooks, campaigns, review discipline. Keep them short — commands, expected output, gates. When a process skill grows a background section beyond a few lines, that is the smell: extract the background into a knowledge skill and link it. Process links to knowledge for the *why*; it never inlines it.
- **Knowledge** (`type: knowledge`) — declarative, "how the system is and why": architecture contracts, domain reference, failure archaeology. This is the long reference layer.

They drift differently, so they re-verify differently. Process skills are nearly self-testing — run the command and drift fails loudly; their re-verify blocks are commands to run. Knowledge skills fail *silently* — which is exactly why the anchor convention and provenance footers below matter most there; their re-verify blocks are greps and anchors to confirm.

Filing rule for new content: tells you *what to do next* → process; tells you *how or why the system is* → knowledge; user-facing rather than agent-facing → it belongs on the docs site, not in a skill (the library must not duplicate the docs of record).

## The two-altitude trust model

Every skill mixes two kinds of content, and they earn different amounts of trust:

- **Durable layer — authoritative.** Doctrine, invariants, mechanisms, architecture contracts, failure archaeology, the *why* behind a decision. This ages slowly. It is the reason the library is worth having, and you can rely on it.
- **Volatile layer — convenience, re-verify before you lean on it.** Anything that a routine code change can invalidate: exact versions, config values, place/universe IDs, "currently…" claims, command output, and any pointer into source. Treat these as a *snapshot with a timestamp*, never as ground truth. If a decision is high-stakes, re-derive the fact from the repo first.

When the two disagree, the repo wins over the skill, and the durable layer wins over the volatile layer. A skill that is confidently wrong is worse than no skill, because it substitutes for looking — so the volatile layer is deliberately fenced off and dated.

## Locate source by anchor, never by line number

**Do not cite source by line number.** Line numbers rot on the next edit to the file and there is no cheap way to notice they've gone stale — an agent will confidently read the wrong lines. Every pointer into source must be a **grep-able anchor**: a function name, constant, type, setting key, or a short distinctive string or comment.

- Bad: ``the guard in `.lute/build.luau` (lines 100–105)``
- Good: ``the `if not process.env.BASE_URL` guard in `.lute/build.luau` (grep `not process.env.BASE_URL`)``

Before you write an anchor, open the file and confirm the token exists and is distinctive enough to locate. Never invent one. If nothing stable marks the spot, name the file and the symbol/section and say what to look for — still no line number. The one exception: line references *into a code or output block printed inside the skill itself* are self-contained and fine.

**Paths are always repo-relative, never absolute.** A command, path, or embedded snapshot that hardcodes `/Users/you/...` (or any machine-specific prefix) fails or silently misleads on every other clone. Write paths relative to the repo root (`.lute/build.luau`, `Packages/_Index/`); reference sibling checkouts as `../storyteller/...`; in scripts, derive the root at runtime (the diagnostics scripts use `path.dirname(debug.info(1, "s"))`, not a literal). If you paste real command output that contains an absolute path (e.g. a build-cache key), redact the prefix to `<REPO_ROOT>`. This is the same failure mode as line numbers — a convenience that rots the moment it leaves your machine.

## The maintenance norm — this is the forcing function

Skills do not heal themselves. An agent only updates a skill if it is told to, so this is the standing rule:

> **When work you are doing contradicts a skill you loaded, fix the skill in the same PR as the work.** Renamed the symbol an anchor points at? Re-point it. Changed the config a table documents? Update the row and its date stamp. Proved a "known bug" is fixed? Move it to resolved in the failure archaeology.

This keeps drift local and cheap. A skill that is touched every time its subject changes never drifts far. Skipping it exports a bigger, colder debugging cost to whoever trusts the skill next.

Reviewers: when a PR changes something a skill documents, the matching skill edit is part of the review, the same way a public API change expects a doc change.

## Every skill carries its own re-verification kit

Follow the structure already documented in `flipbook-docs-and-writing` (frontmatter rules, "When not to use", numbered body, **Provenance and Maintenance** footer). The footer is load-bearing:

- **`Date stamped:` / `Last verified:`** — when the volatile layer was last checked against the repo.
- **`Re-verify these claims when this skill next loads:`** — a short list of exact commands or greps that re-derive the perishable facts. This is what turns "self-healing in principle" into "self-healing in fact." When you rely on the volatile layer, run this block first; when you edit the skill, refresh the date.

Where drift can be checked mechanically, prefer a script over prose — see the executable drift detectors in `flipbook-diagnostics-and-tooling` (`detect-env-drift.luau`, `check-sourcemap-freshness.luau`) for the pattern. A script that compares a skill's claim to live repo state is the strongest form of self-healing we have; add one whenever a fact is both important and mechanically checkable.

## Authoring checklist

- [ ] Durable claims stated plainly; volatile claims fenced into tables/footers and dated.
- [ ] Zero line-number pointers into source — anchors only, each verified present in the repo.
- [ ] Zero absolute/machine-specific paths — repo-relative, `../sibling` for sibling repos, runtime-derived in scripts.
- [ ] Frontmatter `description` says exactly *when to load* (trigger-rich "Use when:") and `type:` declares the genre.
- [ ] Project Skills index in AGENTS.md updated if the skill is new, renamed, or retired.
- [ ] "When not to use" links sibling skills so the right one wins.
- [ ] Provenance footer with a date stamp and a runnable re-verify block.
- [ ] Cross-skill ownership noted where plans/campaigns supersede older material (link the owner skill).
