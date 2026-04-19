---
notion-id: 2db95b79-12f8-814b-88d0-c6d7093ea31a
aliases: [Overview]
linter-yaml-title-alias: Overview
---

# Changewright CLI

> [!tip] 💡
> There's already an action for this:
> https://github.com/mikepenz/release-changelog-builder-action

# Overview

Incrementally build changelogs and manage which version comes next.

For each PR, contributors include a new `.md` file in a central `.changes` directory. Each entry includes a small blurb about the changes being made, along with frontmatter to control

Lute-powered CLI tool with a companion GitHub Action

# Problem

Writing changelogs is not fun, especially when having to contribute to a giant [CHANGELOG.md](http://changelog.md/) with dates and versions that keep moving out from under you, all while juggling other merge conflicts along the way.

Writing out what's changed should be an everyday part of the PR authoring process. And it should be fun! And engaging! A changelog is important not just for historic reasons but also for consumers of a project to quickly find the information most relevant to them. Breaking changes? Bug fixes? New features? All of this is important to capture

# Commands

```lua
changerwright init
    help = "Creates the changewright.toml file for configuring the tool"
changewrite check
    help = "Validates that the pending changelog entries are correctly formatted"
changewright release
    help = "Dumps all of the pending changelog entries into the changelog file."
changewright next-version
    help = "Based off of all of the new entries in .changes, this command will print out the next semantic version once the changes are released"
```

# Requirements

1. Changelog entries are individually written as `.md` and placed in a central directory (default: `.changes` )
2. Changelog entries can include frontmatter that is used to determine what the collective version bump should be
3. Optional configuration file (`changewright.toml`)
4. Support patterns for updating versions in `rotriever.toml`, `wally.toml`, `package.json`, and others?

# Configuration File

```lua
[config]
changes_dir = ".changes"
changelog_file = "CHANGELOG.md"
```

# Algorithm

5. Keep around a `.changes` folder where all of the individual changelog entries will live as `.md` files
6. Each changelog entry includes some frontmatter to determine which package it effects, and whether it should bump the major/minor/patch version
7. All of the version bumps are collected, and we then determine which number to increment
    1. If there's at least one `major` version bump, then we bump to `x.0.0`, if no `major` and at least one `minor`, bump to `x.y.0` where `x` is the current major version, and so on
8. Write current changes to the changelog
9. Need a way to enforce changelog entries by default, with a way to opt-out if certain conditions are met (like `#nonprod` in the PR title). That could maybe be done in a new script to connect Foundation with this program

```lua
---
group: foundation
version: minor
---
Breif description of the changes being made

More details if necessary. Can also include images
```

# Example Filesystem

```lua
some-repo/
	.changes/
		add-new-feature.md
		hello-world.md
		another-entry.md
		README.md
	CHANGELOG.md
	changewright.toml
```

# Task Breakdown

![[Task breakdown.base]]

# Other Ideas

Use the PR as the source of the changelog. Maybe introduce a user-defined bit of markdown to look for (like `# Changelog`) to determine what should be included.

The PR title would be used implicitly and render out something like…

```lua
Fixes:

1. <PR title>
   <Changelog body>
```

A comment is then posted to the PR previewing what the changelog entry will look like in context

# References

* https://github.com/Roblox/foundation/blob/24858edccdf8ff137f3af6d090ba3f1b3da88940/.github/workflows/changelog.yml
* https://github.com/Roblox/foundation/blob/main/scripts/Changes.lua
* [https://roblox.slack.com/archives/C05SS995HCP/p1765819808359729](https://roblox.slack.com/archives/C05SS995HCP/p1765819808359729)

Name ideas:

10. changewright
11. changelog-builder
12. change-curator
13. versionary
14. archivist
15. scribe
16. changelonomicon
