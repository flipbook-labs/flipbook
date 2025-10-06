return {
	-- All paths are relative to the root of the repo
	SOURCE_PATH = "src",
	BUILD_PATH = "build",
	PACKAGES_PATH = "Packages",
	LUNE_SCRIPTS_PATH = ".lune",
	EXAMPLE_PATH = "example",
	WORKSPACE_PATH = "workspace",

	PLUGIN_FILENAME = "Flipbook.rbxm",

	SOURCEMAP_PATH = "sourcemap.json",
	DARKLUA_SOURCEMAP_PATH = "sourcemap-darklua.json",

	ROJO_ANALYSIS_PROJECT = "analysis.project.json",
	ROJO_BUILD_PROJECT = "build.project.json",
	ROJO_TESTS_PROJECT = "tests.project.json",

	FOLDERS_TO_LINT = {
		"src",
		".lune",

		-- We have to exhaustively include every workspace member to skip over
		-- Packages/RobloxPackages
		"workspace/flipbook-core/src",
		"workspace/example/src",
		"workspace/code-samples/src",
		"workspace/test-runner/src",
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
