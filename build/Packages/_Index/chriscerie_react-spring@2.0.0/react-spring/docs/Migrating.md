---
sidebar_position: 1000
---

# Migrating

## v1 to v2

* react-spring 2.0 switches React and ReactRoblox wally scope from corepackages to [jsdotlua](https://github.com/jsdotlua). To prevent duplicated React packages, your project must also switch wally dependencies to the new jsdotlua scope. rbxts and legacy roact users are not affected by this breaking change.

## v0 to v1

* roact-spring 1.0 bumps its promise dependency [from v3 to v4](https://github.com/evaera/roblox-lua-promise/releases/tag/v4.0.0). To migrate, ensure any usage of promises owned by roact-spring (e.g., using `api.start():andThen()`) is compatible with promise v4.
