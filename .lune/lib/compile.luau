local fs = require("@lune/fs")
local project = require("@repo/project")
local run = require("./run")
local serde = require("@lune/serde")

local wallyToml = serde.decode("toml", fs.readFile("wally.toml"))

type Channel = "prod" | "dev"

local PROD_CONFIG = {
	prunedDirs = {
		"workspace/code-samples",
		"workspace/example",
		"workspace/test-runner",
	},
	prunedFiles = {
		"*.spec.lua*",
		"*.story.lua*",
		"*.storybook.lua*",
		"jest.config.lua*",
	},
}

local function compile(channel: Channel)
	local dest = `{project.BUILD_PATH}/plugin`

	if fs.isDir(dest) then
		fs.removeDir(dest)
	end
	fs.writeDir(dest)

	local commitHash = run("git", { "rev-parse", "--short", "HEAD" })

	local env = {
		BUILD_VERSION = wallyToml.package.version,
		BUILD_CHANNEL = if channel == "prod" then "production" else "development",
		BUILD_HASH = commitHash,
	}

	run("rojo", {
		"sourcemap",
		project.ROJO_BUILD_PROJECT,
		"-o",
		project.DARKLUA_SOURCEMAP_PATH,
	})

	print("substituting globals", env)

	run("darklua", {
		"process",
		project.SOURCE_PATH,
		dest,
	}, {
		env = env,
	})

	for _, member in fs.readDir(project.WORKSPACE_PATH) do
		local memberPath = `{project.WORKSPACE_PATH}/{member}`

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

	if channel == "prod" then
		for _, dir in PROD_CONFIG.prunedDirs do
			run("rm", { "-rf", `{dest}/{dir}` })
		end

		for _, pattern in PROD_CONFIG.prunedFiles do
			run("find", { dest, "-type", "f", "-name", pattern, "-delete" })
		end
	end
end

return compile
