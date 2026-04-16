local path = require("@std/path")

return {
	REPO_PATH = path.resolve("."),
	SOURCE_PATH = path.resolve("./src"),
	BUILD_PATH = path.resolve("./build"),
	BUILD_CACHE_PATH = path.resolve("./build/build-cache.json"),
	PACKAGES_PATH = path.resolve("./Packages"),
	ROBLOX_PACKAGES_PATH = path.resolve("./RobloxPackages"),
	ROBLOX_PACKAGES_VERSION = "0.715.0.7151115",
	SCRIPTS_PATH = path.resolve("./.lute"),
	EXAMPLE_PATH = path.resolve("./example"),
	WORKSPACE_PATH = path.resolve("./workspace"),
	LUAU_PACKAGES_PATH = path.resolve("./LuauPackages"),

	PLUGIN_FILENAME = "Flipbook.rbxm",

	SOURCEMAP_PATH = path.resolve("./sourcemap.json"),
	DARKLUA_SOURCEMAP_PATH = path.resolve("./sourcemap-darklua.json"),

	ROJO_BUILD_PROJECT = path.resolve("./build.project.json"),
	ROJO_TESTS_PROJECT = path.resolve("./tests.project.json"),

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

	EXPERIENCES = {
		-- Primary experience we use for running Flipbook's unit tests.
		unitTesting = {
			universeId = "6599100156",
			placeId = "123506190725771",
		},

		-- Sandbox for running unit tests against contributions from the
		-- community. This is to facillitate fork-based workflows.
		forkSandbox = {
			universeId = "10043718755",
			placeId = "123308720788536",
		},
	},
}
