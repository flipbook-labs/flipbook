---
aliases: [Flipbook Mounts Anywhere]
linter-yaml-title-alias: Flipbook Mounts Anywhere
---

# Flipbook Mounts Anywhere

Flipbook runs in more places than its plugin widget. Each surface below is one of them, and the table says who can use Flipbook there. "Read" means browsing Storybooks and Stories. "Write" means changing what's shown, such as opening a Story, setting its controls, and interacting with it. An agent drives Flipbook through AgentGateway and Studio MCP, and the last two columns say what it needs to capture on each surface.

| Surface              | Mounts under                         | Person                    | Agent          | Screenshot | Video    |
| -------------------- | ------------------------------------ | ------------------------- | -------------- | ---------- | -------- |
| Plugin widget        | `DockWidgetPluginGui`, Edit mode     | Read and write            | Read and write | Required   | Goal     |
| Story in viewport    | `StarterGui`, Edit mode              | Read and write            | Read and write | Required   | Goal     |
| App in Edit viewport | `StarterGui`, Edit mode              | Read and write            | Read and write | Required   | Goal     |
| Embedded in Play     | `PlayerGui`, Play mode               | Read and write            | Read and write | Required   | Required |
| Deployed Storybook   | `PlayerGui`, its own published place | Read, plus control values | None           | None       | None     |

The agent columns show where agent support is headed, tracked in [#721](https://github.com/flipbook-labs/flipbook/issues/721). A video marked Goal is wanted but not required until recording there has been tried.

Some of the table isn't true yet. The Story in viewport mounts under `CoreGui` today, and it moves to `StarterGui` because Studio MCP's screenshots leave out `CoreGui` and virtual input can't press anything there. The app in the Edit viewport waits on [#717](https://github.com/flipbook-labs/flipbook/pull/717). Until both land, embedded Flipbook in Play mode is the only surface an agent can capture as it is.

UI PNG exports are another planned mount, under `CoreGui`.

## References

- [#369](https://github.com/flipbook-labs/flipbook/issues/369)
- [#274](https://github.com/flipbook-labs/flipbook/issues/274)
- [#721](https://github.com/flipbook-labs/flipbook/issues/721)
