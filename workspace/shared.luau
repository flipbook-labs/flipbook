-- Values every workspace member's `pkg.luau` reads, so they stay the same
-- across members. The root `pkg.luau` and `project.luau` read them too.

-- Files left out of production builds. The build prunes them with these
-- patterns, and each member's `files` excludes them from its package.
local PRUNED_FILES = {
	"*.spec.lua*",
	"*.story.lua*",
	"*.storybook.lua*",
	"jest.config.lua*",
}

-- A member's package is its `src` folder without the pruned files. `files`
-- uses gitignore-style patterns, and a `!` pattern excludes what it matches.
local files = { "src/**" }
for _, pattern in PRUNED_FILES do
	table.insert(files, `!{pattern}`)
end

return table.freeze({
	-- Flipbook's version. changewrite bumps it here along with the other
	-- manifests listed in `changewrite.luau`.
	version = "2.5.0",
	prunedFiles = table.freeze(PRUNED_FILES),
	files = table.freeze(files),
})
