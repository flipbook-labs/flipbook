local path = require("@std/path")

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
	LUAU_PACKAGES_PATH = path.resolve("./LuauPackages"),

	PLUGIN_FILENAME = "Flipbook.rbxm",

	SOURCEMAP_PATH = path.resolve("./sourcemap.json"),
	SOURCEMAP_PROJECT_PATH = path.resolve("./sourcemap.project.json"),
	BUILD_SOURCEMAP_PATH = path.resolve("./sourcemap-build.json"),

	-- `_G` globals the build replaces with their values, read from the
	-- build's environment. A global with no value there becomes `nil`.
	BUILD_GLOBALS = {
		"BUILD_VERSION",
		"BUILD_CHANNEL",
		"BUILD_HASH",
		"BUILD_TARGET",
		"BASE_URL",
		"LOG_LEVEL",
		"ENABLE_OUTPUT_LOGGING",
		"JEST_TEST_PATH_PATTERN",
	},

	FOLDERS_TO_LINT = {
		"src",
		"workspace",
		".lute",
	},

	PROD_CONFIG = {
		prunedDirs = {
			path.resolve("./workspace/code-samples"),
			path.resolve("./workspace/example"),
			path.resolve("./workspace/template"),
			path.resolve("./workspace/test-runner"),
		},
		prunedFiles = {
			"*.spec.lua*",
			"*.story.lua*",
			"*.storybook.lua*",
			"jest.config.lua*",
		},
	},

	ROBLOX_STORYBOOK_UNIVERSE_ID = 10262009842,
	ROBLOX_STORYBOOK_PLACE_ID = 139676401890813,
}
