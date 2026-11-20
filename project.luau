local path = require("@std/path")

local manifest = require("./pkg")
local shared = require("./workspace/shared")

type DependencySpec = { sourceKind: string, source: string? }

-- Workspace members are the path dependencies in the root `pkg.luau`.
local function getMemberPaths(dependencies: { [string]: DependencySpec }): { path.Path }
	local sources: { string } = {}
	for _, spec in dependencies do
		if spec.sourceKind == "path" and spec.source then
			table.insert(sources, spec.source)
		end
	end
	table.sort(sources)

	local paths: { path.Path } = {}
	for _, source in sources do
		table.insert(paths, path.resolve(source))
	end
	return paths
end

local shippedMemberPaths = getMemberPaths(manifest.package.dependencies :: any)
local devMemberPaths = getMemberPaths(manifest.package.dev_dependencies :: any)

local memberPaths = table.clone(shippedMemberPaths)
table.move(devMemberPaths, 1, #devMemberPaths, #memberPaths + 1, memberPaths)

return {
	REPO_PATH = path.resolve("."),
	SOURCE_PATH = path.resolve("./src"),
	BUILD_PATH = path.resolve("./build"),
	BUILD_CACHE_PATH = path.resolve("./build/build-cache.json"),
	PACKAGES_PATH = path.resolve("./Packages"),
	ROBLOX_PACKAGES_PATH = path.resolve("./RobloxPackages"),
	ROBLOX_PACKAGES_VERSION = "0.747.0.7471481",
	SCRIPTS_PATH = path.resolve("./.lute"),
	EXAMPLE_PATH = path.resolve("./example"),
	WORKSPACE_PATH = path.resolve("./workspace"),
	WORKSPACE_MEMBER_PATHS = memberPaths,
	LUAU_PACKAGES_PATH = path.resolve("./LuauPackages"),

	PLUGIN_FILENAME = "Flipbook.rbxm",

	SOURCEMAP_PATH = path.resolve("./sourcemap.json"),
	SOURCEMAP_PROJECT_PATH = path.resolve("./sourcemap.project.json"),
	DARKLUA_SOURCEMAP_PATH = path.resolve("./sourcemap-darklua.json"),

	FOLDERS_TO_LINT = {
		"src",
		"workspace",
		".lute",
	},

	PROD_CONFIG = {
		-- Members that are dev dependencies in `pkg.luau` don't ship.
		prunedDirs = devMemberPaths,
		prunedFiles = shared.prunedFiles,
	},

	ROBLOX_STORYBOOK_UNIVERSE_ID = 10262009842,
	ROBLOX_STORYBOOK_PLACE_ID = 139676401890813,
}
