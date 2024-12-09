return {
	-- All paths are relative to the root of the repo
	SOURCE_PATH = "src",
	BUILD_PATH = "build",
	PACKAGES_PATH = "Packages",
	LUNE_SCRIPTS_PATH = ".lune",
	EXAMPLE_PATH = "example",

	PLUGIN_FILENAME = "Flipbook.rbxm",

	SOURCEMAP_PATH = "sourcemap.json",
	DARKLUA_SOURCEMAP_PATH = "sourcemap-darklua.json",

	ROJO_ANALYSIS_PROJECT = "analysis.project.json",
	ROJO_BUILD_PROJECT = "build.project.json",
	ROJO_TESTS_PROJECT = "tests.project.json",

	FOLDERS_TO_LINT = {
		"src",
		".lune",
		"example",
		"code-samples/src",
	},
}
