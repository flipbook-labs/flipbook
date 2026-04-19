---
aliases: [RobloxInternal Package]
linter-yaml-title-alias: RobloxInternal Package
notion-id: 27695b79-12f8-81d7-9c29-c2b38020fda1
---

# RobloxInternal Package

## Overview

Create a new package that can be used by Flipbook, Storyteller, and any other package that needs to interface with internal Roblox features

## API

### canAccess

`canAccess(instance: Instance): boolean`

Checks whether the current script context can access an Instance.

This is used to ensure services like `CorePackages` can be indexed before attempting to read anything.

### tryGetService

`tryGetService(serviceName: string): unknown?`

Normally `GetService` will throw an error if the current script context cannot access a service. This function instead returns nil in those cases so we can fallback when `CorePackages`, `CoreGui`, and `FileSyncService` are inaccessible.

### getInternalSyncItems

`getInternalSyncItems(): { InternalSyncItem }`

`InternalSyncItems` represent links between Instances to the filesystem. This function returns a list of them since there’s not an engine API for that purpose.

### getMostLikelyProjectSources

`getMostLikelyProjectSources(): { InternalSyncItem }`

Returns InternalSyncItems sorted by the ones most likely to represent the project’s root folder.

This gets murky in cases where Rotriever workspaces are used, so it cannot be relied on fully for all usage.

```javascript
RobloxInternal
    canAccess(instance: Instance): boolean
    tryGetService(serviceName: string): unknown?
    getInternalSyncItems(): { InternalSyncItem }
    getMostLikelyProjectSources(): { InternalSyncItem }
```
