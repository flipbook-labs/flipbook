# Flipbook — Agent Instructions

## Running scripts

Scripts live in `.lute/` and are invoked with `lute run <script-name>`.

## API keys

`.env` is not sourced automatically. Run `source .env` before any `lute run` command that needs an API key:

```bash
source .env && lute run <command>
```

Commands that require this: `lute run test`, `lute run deploy-storybook`, `lute run upload-storybook-runtime`.

## Common commands

| Command | Description |
|---------|-------------|
| `lute run analyze` | Type checking |
| `lute run test` | Unit tests (needs `ROBLOX_API_KEY`; add `--filter <path>` to run a subset) |
| `lute run build` | Build the plugin |
| `lute run deploy-storybook` | Deploy the storybook preview (needs `ROBLOX_STORYBOOK_PREVIEW_API_KEY`) |
| `lute run upload-storybook-runtime` | Upload Flipbook.rbxm as a Roblox asset (needs `ROBLOX_API_KEY`) |
