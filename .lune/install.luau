local run = require("./lib/run")

do
	run("wally", { "install" })
	run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" })
	run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" })
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
	})
end
