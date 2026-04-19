---
aliases: [Luau API Diffing]
linter-yaml-title-alias: Luau API Diffing
notion-id: 2d895b79-12f8-8075-b8f5-cfc89f6708a5
---
# Luau API Diffing

## Overview

CLI tool (and Luau package) for determining the changes to a public Luau API and generating a report on what changes were made

## Inputs

1. Path to a Luau file to use as the base entrypoint of an API. Typically an `init.luau` file
2. Path to another Luau file to use as the comparison. Same as above

The entire dependency graph is required, so each of the files to compare need to also include all the other source code necessary to build out the public API

## **Outputs**

3. Markdown report on what changed, including additions, changes, and removals, making it possible to know which version component to increment (major, minor, or patch)
4. JSON equivalent of the report that can be passed off to other tools

## Implementation

### Version Bumping Schema

* Breaking change: Major
* Additions only: Minor version
* Modifications that don’t change the public API: Patch

### Determining Changes

```javascript
Tool for surfacing breaking changes
	Post PR comment with diff of the last version and the most recent commit

	Focus mainly on analysis the type surface

	Somehow support flags
```

5. Additions and removals are straightforward, we just need to parse the `init.luau` file to see if any `export type` lines have been added or removed, and if anything has changed in the resulting object that the module exports.
6. Detecting when the API surface changes beyond that though is going to be tricky. Lute has an [AST parser built into the std lib](https://lute.luau.org/reference/std/syntax/syntax.html) that may help here. What we need to do is compare types from the entrypoint all the way down the require graph.

## Questions

7. Do we need to account for cases like ReactTestingLibrary where the API exports aren’t clearly defined? It uses a lot of object merging to reach its final exports, which messes up Luau analysis. So if tools like luau-lsp can’t parse it, I don’t think we can either for diffing the API
8. How can this be written so that major version bumps won’t break CI? With the way I have it now, this is a “backwards compat forever” tool
    1. Perhaps the goal of this tool should be to inform rather than restrict. There will be plenty of reason to allow breaking changes to rollover between PRs. The idea will be to inform authors and we can do this by showing them what’s changed from their PR and what’s changed overall since the last version
    2. And perhaps it could be used as a PR comment to show the diff of, for example, the last major version and the most recent commit to the branch.
