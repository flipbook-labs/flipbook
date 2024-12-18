local process = require("@lune/process")

local run = require("./lib/run")

local function installPackageFromDisk(packageName: string, packagePath: string, runOptions: { [string]: any }?)
	local homePath = process.env.HOME
	assert(homePath, "no $HOME env var")

	local absPackagePath = run("realpath", { packagePath })

	run("rm", { `Packages/{packageName}.lua` }, runOptions)
	run("ln", { "-s", `{absPackagePath}/dist`, `Packages/{packageName}` }, runOptions)
end

do
	run("wally", { "install" })

	installPackageFromDisk("Storyteller", "../storyteller")
	installPackageFromDisk("ModuleLoader", "../module-loader")

	run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" })
	run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" })
end

do
	run("wally", { "install" }, {
		cwd = "code-samples",
	})

	installPackageFromDisk("Storyteller", "../storyteller", {
		cwd = "code-samples",
	})

	run("rojo", { "sourcemap", "default.project.json", "-o", "sourcemap.json" }, {
		cwd = "code-samples",
	})
	run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" }, {
		cwd = "code-samples",
	})
end
