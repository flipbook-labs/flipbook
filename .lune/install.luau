local run = require("./lib/run")

do
	run("wally", { "install" })
	run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" })

	-- For some reason the default stdio of "inherit" results in WPT hanging indefinitely. Since we don't need the output in this case, we change to a stdio that won't hang
	run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" }, {
		stdio = "forward",
	})
end

do
	run("wally", { "install" }, {
		cwd = "code-samples",
	})
	run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" }, {
		cwd = "code-samples",
	})
	run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" }, {
		cwd = "code-samples",
		stdio = "forward",
	})
end
