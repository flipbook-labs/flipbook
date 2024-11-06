local run = require("./lib/run")

run("wally", { "install" })

do
	local process = require("@lune/process")

	local homePath = process.env.HOME
	assert(homePath, "no $HOME env var")

	local storytellerPath = run("realpath", { "../storyteller" })

	run("rm", { `Packages/Storyteller.lua` })

	run("lune", { "run", "build" }, {
		cwd = storytellerPath,
	})

	run("ln", { "-s", `{storytellerPath}/dist`, `Packages/Storyteller` })
end

run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" })
run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" })
