return {
	bump = "patch",
	category = "Dependencies",
	kind = "packages",
	summary = "Upgrade Storyteller to v1.13.0 and ModuleLoader to v0.13.0, so stories can use `.config` aliases on engines that support them.",
	body = "ModuleLoader also loads stories with `debug.loadmodule` when running at RobloxScript security, and an error inside a chain of requires prints one stack traceback.",
}
