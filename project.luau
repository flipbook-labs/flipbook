return {
	-- All paths are relative to the root of the repo
	SOURCE_PATH = "src",
	BUILD_PATH = "build",
	BUILD_CACHE_PATH = "build/build-cache.json",
	PACKAGES_PATH = "Packages",
	ROBLOX_PACKAGES_PATH = "RobloxPackages",
	ROBLOX_PACKAGES_VERSION = "0.697.0.6970925",
	SCRIPTS_PATH = "scripts",
	EXAMPLE_PATH = "example",
	WORKSPACE_PATH = "workspace",

	PLUGIN_FILENAME = "Flipbook.rbxm",

	SOURCEMAP_PATH = "sourcemap.json",
	DARKLUA_SOURCEMAP_PATH = "sourcemap-darklua.json",

	ROJO_BUILD_PROJECT = "build.project.json",
	ROJO_TESTS_PROJECT = "tests.project.json",

	FOLDERS_TO_LINT = {
		"src",
		"scripts",
	},

	PROD_CONFIG = {
		prunedDirs = {
			"workspace/code-samples",
			"workspace/example",
			"workspace/template",
			"workspace/test-runner",
		},
		prunedFiles = {
			"*.spec.lua*",
			"*.story.lua*",
			"*.storybook.lua*",
			"jest.config.lua*",
		},
	},
}
