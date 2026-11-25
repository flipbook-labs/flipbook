-- The root has no name or version, which makes it a virtual package: it
-- isn't a package itself, and its path dependencies are the workspace
-- members. Members in `dependencies` ship with the plugin. Members in
-- `dev_dependencies` only exist for development, so production builds prune
-- them. The other dependencies are tooling for the `.lute` scripts.
local function member(name: string)
	return { sourceKind = "path", source = `./workspace/{name}` }
end

-- Files that production builds leave out of the workspace members. The build
-- prunes them with these patterns, and each member's `files` excludes them too.
local PRUNED_FILES = {
	"*.spec.lua*",
	"*.story.lua*",
	"*.storybook.lua*",
	"jest.config.lua*",
}

-- A member's package is its `src` folder without the pruned files. `files`
-- uses gitignore-style patterns, and a `!` pattern excludes what it matches.
local memberFiles = { "src/**" }
for _, pattern in PRUNED_FILES do
	table.insert(memberFiles, `!{pattern}`)
end

return {
	package = {
		-- A package can keep any data it wants in `metadata`. Each member's
		-- `pkg.luau` reads its version and files from this one, so they stay the
		-- same across members. The version can't be a field of the root itself,
		-- because then the root wouldn't be virtual.
		metadata = {
			-- Flipbook's version. changewrite bumps it here along with the other
			-- manifests listed in `changewrite.luau`.
			version = "2.6.0",
			memberFiles = memberFiles,
			prunedFiles = PRUNED_FILES,
		},
		dependencies = {
			["flipbook-agents"] = member("flipbook-agents"),
			["flipbook-core"] = member("flipbook-core"),
			["flipbook-next"] = member("flipbook-next"),
			["flipbook-telemetry"] = member("flipbook-telemetry"),

			batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
			["flipbook-batteries"] = {
				rev = "v0.13.1",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
		},
		dev_dependencies = {
			["code-samples"] = member("code-samples"),
			example = member("example"),
			template = member("template"),
			["test-runner"] = member("test-runner"),

			["agent-skills"] = {
				rev = "v0.9.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
			["code-quality"] = {
				rev = "v0.8.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/code-quality",
			},
		},
	},
}
