local process = require("@lune/process")

local run = require("./lib/run")

run("wally", { "install" })

local function installPackageFromDisk(packageName: string, packagePath: string)
	local homePath = process.env.HOME
	assert(homePath, "no $HOME env var")

	local absPackagePath = run("realpath", { packagePath })

	run("rm", { `Packages/{packageName}.lua` })

	run("lune", { "run", "wally-install" }, {
		cwd = absPackagePath,
	})

	run("lune", { "run", "build" }, {
		cwd = absPackagePath,
	})

	run("ln", { "-s", `{absPackagePath}/dist`, `Packages/{packageName}` })
end

installPackageFromDisk("Storyteller", "../storyteller")
installPackageFromDisk("ModuleLoader", "../module-loader")

run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" })
run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" })
