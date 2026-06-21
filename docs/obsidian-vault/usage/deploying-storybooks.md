---
aliases: [Deploying Storybooks]
linter-yaml-title-alias: Deploying Storybooks
---

# Deploying Storybooks

You can share a live storybook preview with your team by deploying it to a dedicated Roblox experience. Each story you write is immediately playable from any browser via the experience's direct link, no Studio required.

Two tools handle this:

- **[flipbook-cli](https://github.com/flipbook-labs/flipbook-cli)**: a standalone CLI you can run locally or from any CI environment
- **[deploy-storybook](https://github.com/flipbook-labs/deploy-storybook)**: a GitHub Action that wraps the CLI for automated deployments

## Setup

### Create the Preview Experience

1. Go to [Creator Hub](https://create.roblox.com/dashboard/creations) and create a new experience.
2. Note the **UniverseId** and **PlaceId**. You'll need these later.
3. Close the experience in Studio after publishing to avoid conflicts during deploys.
4. Open the start place settings and enable **Direct Access Control > Fully Open**. This is what makes stable, shareable deep-links to each story work.

### Create an Open Cloud API Key

1. Go to [Creator Hub > Credentials](https://create.roblox.com/dashboard/credentials).
2. Click **Create API Key** and scope it to your storybook experience.
3. Grant it `universe-places:write` access (and `universe.place.luau-execution-session` access if you need it).
4. Copy the generated key.

### Add Secrets to Your Repository

In **Settings > Environments** (or **Secrets and variables > Actions**):

| Name                           | Type     | Value                      |
| ------------------------------ | -------- | -------------------------- |
| `ROBLOX_API_KEY`               | Secret   | The Open Cloud API key     |
| `ROBLOX_STORYBOOK_UNIVERSE_ID` | Variable | The UniverseId from step 1 |

## Using the GitHub Action

Add the `deploy-storybook` Action to your workflow. Build your storybook `.rbxl` beforehand (e.g. with Rojo), then pass it as `place-file`.

### Deploy on Every Push to Main

```yaml
name: Deploy storybook
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Build storybook
        run: rojo build storybook.project.json -o storybook.rbxl

      - uses: flipbook-labs/deploy-storybook@v1
        with:
          api-key: ${{ secrets.ROBLOX_API_KEY }}
          universe-id: ${{ vars.ROBLOX_STORYBOOK_UNIVERSE_ID }}
          place-name: Flipbook Stories
          place-file: storybook.rbxl
```

### Per-PR Preview Deploys

Each pull request gets its own named place and a comment with the preview link:

```yaml
name: Deploy storybook
on:
  pull_request:

permissions:
  pull-requests: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: storybook-preview
    steps:
      - uses: actions/checkout@v4

      - name: Build storybook
        run: rojo build storybook.project.json -o storybook.rbxl

      - uses: flipbook-labs/deploy-storybook@v1
        with:
          api-key: ${{ secrets.ROBLOX_API_KEY }}
          universe-id: ${{ vars.ROBLOX_STORYBOOK_UNIVERSE_ID }}
          place-name: "PR ${{ github.event.pull_request.number }}"
          place-file: storybook.rbxl
```

The Action resolves the place by name and creates it if it doesn't exist yet. Pass an explicit `place-id` if you have multiple places with the same name.

### Action Inputs

| Input           | Required | Description                                                    | Default  |
| --------------- | -------- | -------------------------------------------------------------- | -------- |
| `api-key`       | yes      | Roblox Open Cloud API key                                      |          |
| `universe-id`   | yes      | Universe (experience) ID to deploy to                          |          |
| `place-name`    | yes      | Name of the place to update or create                          |          |
| `place-file`    | yes      | Path to the built `.rbxl` place file                           |          |
| `place-id`      | no       | Explicit place ID; disambiguates same-named places             |          |
| `flipbook-rbxm` | no       | Path to a local `Flipbook.rbxm`; skips downloading from GitHub |          |
| `comment`       | no       | Post a preview comment on the PR after deploy                  | `'true'` |

## Using Flipbook-cli Directly

Install via Rokit:

```sh
rokit add flipbook-labs/flipbook-cli
```

Deploy a storybook place:

```sh
flipbook-cli deploy \
  --universe-id 123 \
  --place-name "Flipbook Stories" \
  --place-file out.rbxl
```

Pass `--api-key` or set the `ROBLOX_API_KEY` environment variable.

The deploy command:

1. Resolves `--place-name` to a place in the universe (or creates one via `CreatePlaceAsync` from the start place).
2. Publishes `--place-file` to that place.
3. Injects the latest Flipbook runtime into `ReplicatedStorage.Flipbook`.

> [!seealso]
> [[usage/getting-started|Getting Started]]: Writing your first story
> [[engineering/ecosystem|Ecosystem]]: Overview of all flipbook-labs repos
