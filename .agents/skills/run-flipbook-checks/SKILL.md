---
name: run-flipbook-checks
description: Run validation checks in Flipbook, Storyteller, or ModuleLoader. Use when the user asks to run tests, lint, analyze, CI checks, quality checks, validation, or verify changes in the Flipbook repo family.
---

# Run Flipbook Checks

Use `lute run` tasks before reaching for lower-level commands.

## Quick Reference

```bash
lute run lint
lute run analyze
lute run test
```

`lute run test` runs Jest inside a Roblox place through Rocale and requires `ROBLOX_API_KEY`. If the key is unavailable, say tests could not be run and run `lint`/`analyze` instead when appropriate.

## Lint

```bash
lute run lint
```

Checks:

- Selene
- StyLua `--check`
- Markdown formatting, when configured by the repo
- No `.lua` files; Luau files should use `.luau`

## Analyze

```bash
lute run analyze
```

Runs `luau-lsp` analysis. If local setup is missing, run or recommend `lute run install` based on the failure.

## Tests

```bash
lute run test
lute run test --filter "SomePattern"
lute run test --apiKey "YOUR_KEY"
```

Use `--filter` for focused test runs when the changed area has a clear test pattern.
