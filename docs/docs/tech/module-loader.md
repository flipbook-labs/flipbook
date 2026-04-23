---
aliases: [Module Loader]
linter-yaml-title-alias: Module Loader
notion-id: 2e095b79-12f8-8073-9c5f-e70a6b8ba2a5
---

# Module Loader

|      |                                                                                                              |
| ---- | ------------------------------------------------------------------------------------------------------------ |
| Epic | [https://github.com/flipbook-labs/flipbook/issues/472](https://github.com/flipbook-labs/flipbook/issues/472) |
|      |                                                                                                              |

## Overview

Going to be refactoring the ModuleLoader package this quarter.

Collaborating with the folks that maintain Jest Roblox

## Requirements

1. Support for require-by-string
    1. Supported aliases will be `@self` and `@game`
    2. Relative paths with `./`, `../`, `../../`, etc.
    3. No support for absolute paths like `/foo/bar`
    4. No support for complex paths like `foo/../bar`
2. Great error messages
3. Great recovery from failures
4. RobloxTS support
    5. No walking back _G. If a module is changed, re-require the whole thing
5. Improved story sandboxing
6. Detect when a module changes so the user can re-require
7. Preload modules in the cache
8. [Stretch] Visualize dependency graph

## Open Questions

9. What would be a good way to test `loadmodule` support from a user-level security context?

## Implementation

10.  https://github.com/dphblox/loadsamodule

TODO:

11. Determine all the cases we need to support
    1. Take from test files to build out requirements
12. Use `loadsamodule` as the base
13. Build out test cases based on v0.7.0 tests
15. Release v1.0.0

Things to fix:

16. All Foundation stories and storybooks are unavailable
    1. Seems like despite loadmodule being enabled it still isn't being used to load things
    2. Or there's something else going on. I feel like I've been here before

### Investigations

Flipbook might be hitting the RobloxScript error because it might need to be an Asset plugin. That might be the core difference between Flipbook and Developer Storybook

#### Storyteller DataModel Querying

Looks like Storyteller's query is throwing a fit with the new loading strategy. Probably because each `Clone` is triggering it. Uh oh. I could probably patch this by batching when changes instances are processed

Maybe I need to take another look at `query` to see about slowing it down. This is the same problem as SceneUnderstanding. We need to sensibly parse the entire DataModel for the instances we care about.

Things to try:

17. Budgeting work per frame
    1. React Luau example: [react-luau/modules/scheduler/src/forks/SchedulerHostConfig.default.lua at 731241ae06ab751725dc4a777e8880e0b7b3e741 · Roblox/react-luau](https://github.com/Roblox/react-luau/blob/731241ae06ab751725dc4a777e8880e0b7b3e741/modules/scheduler/src/forks/SchedulerHostConfig.default.lua#L75-L111)
18. Defer before processing as a means of batching
    2. One example: Instance parented to DM, then a bunch of properties get changed. This would trigger an update for each occurrence.
    3. With deferral we could wait some number of frames before processing, allowing instances to “settle” and be processed in one go. Sacrifices some time-to-complete so as not to harm FPS. And this time will likely be imperceptible to the user
19. Add stress tests to make sure `query` can handle some crazy edge cases (like cloning)
20. [Stretch] Keep track of “hot” instances, where if an instance is receiving a bunch of changes to it we could start backing off for that instance, deferring it for processing later

I also want to bang out a flowchart for all the behavior so I can better track the work loop.

## Prior Work

21. [https://github.com/flipbook-labs/storyteller/pull/81](https://github.com/flipbook-labs/storyteller/pull/81)

## Tickets

22. [https://github.com/flipbook-labs/module-loader/issues/31](https://github.com/flipbook-labs/module-loader/issues/31)

## References

23. [Module Resolution | webpack](https://webpack.js.org/concepts/module-resolution/)
24. [Module Federation | webpack](https://webpack.js.org/concepts/module-federation/)
25. [https://roblox.slack.com/archives/C01D2L57GMQ/p1758822277847879](https://roblox.slack.com/archives/C01D2L57GMQ/p1758822277847879)
26. [https://ros.rbx.com/hackweek/projects/5603](https://ros.rbx.com/hackweek/projects/5603)
