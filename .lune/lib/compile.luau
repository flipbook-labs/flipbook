local constants = require("./constants")
local fs = require("@lune/fs")
local run = require("./run")
local serde = require("@lune/serde")

local wallyToml = serde.decode("toml", fs.readFile("wally.toml"))

type Target = "prod" | "dev"

local PROD_CONFIG = {
	prunedDirs = {
		"workspace/code-samples",
		"workspace/example",
	},
	prunedFiles = {
		"*.spec.lua*",
		"*.story.lua*",
		"*.storybook.lua*",
	},
}

local function compile(target: Target)
	local dest = `{constants.BUILD_PATH}/plugin`

	if fs.isDir(dest) then
		fs.removeDir(dest)
	end
	fs.writeDir(dest)

	local commitHash = run("git", { "rev-parse", "--short", "HEAD" })

	local env = {
		BUILD_VERSION = wallyToml.package.version,
		BUILD_CHANNEL = if target == "prod" then "production" else "development",
		BUILD_HASH = commitHash,
	}

	run("rojo", {
		"sourcemap",
		constants.ROJO_BUILD_PROJECT,
		"-o",
		constants.DARKLUA_SOURCEMAP_PATH,
	})

	print("substituting globals", env)

	run("darklua", {
		"process",
		constants.SOURCE_PATH,
		dest,
	}, {
		env = env,
	})

	for _, member in fs.readDir(constants.WORKSPACE_PATH) do
		local memberPath = `{constants.WORKSPACE_PATH}/{member}`

		if not fs.isDir(memberPath) then
			continue
		end

		run("darklua", {
			"process",
			`{memberPath}/src`,
			`{dest}/{memberPath}`,
		}, {
			env = env,
		})

		local packagesPath = `{memberPath}/Packages`
		run("cp", { "-R", packagesPath, `{dest}/{packagesPath}` })

		local robloxPackagesPath = `{memberPath}/RobloxPackages`
		if fs.isDir(robloxPackagesPath) then
			run("cp", { "-R", robloxPackagesPath, `{dest}/{robloxPackagesPath}` })
		end
	end

	if target == "prod" then
		for _, dir in PROD_CONFIG.prunedDirs do
			run("rm", { "-rf", `{dest}/{dir}` })
		end

		for _, pattern in PROD_CONFIG.prunedFiles do
			run("find", { dest, "-type", "f", "-name", pattern, "-delete" })
		end
	end

	run("cp", { "-R", "Packages", dest })
end

return compile
