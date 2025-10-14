local fs = require("@lute/fs")
local project = require("@repo/project")
local toml = require("@batteries/toml")

local find = require("./find")
local run = require("./run")

local wallyToml = toml.deserialize(fs.readfiletostring("wally.toml"))

type Channel = "prod" | "dev"
type Target = "roblox" | "rotriever"

local function compileWorkspaceMember(
	memberPath: string,
	channel: Channel,
	target: Target,
	env: { [string]: any }
): string
	local memberBuildPath = `{memberPath}/build`

	if fs.type(memberBuildPath) == "dir" then
		run("rm", { "-rf", memberBuildPath })
	end
	fs.mkdir(memberBuildPath)

	run("darklua", {
		"process",
		`{memberPath}/src`,
		memberBuildPath,
	}, {
		env = env,
	})

	local packagesPath = `{memberPath}/Packages`
	run("cp", { "-R", packagesPath, `{memberBuildPath}/Packages` })

	local robloxPackagesPath = `{memberPath}/RobloxPackages`
	if fs.exists(robloxPackagesPath) then
		run("cp", { "-R", robloxPackagesPath, `{memberBuildPath}/RobloxPackages` })
	end

	if channel == "prod" then
		for _, pattern in project.PROD_CONFIG.prunedFiles do
			run("find", { memberBuildPath, "-type", "f", "-name", `"{pattern}"`, "-delete" })
		end
	end

	if target == "rotriever" then
		-- Rotriever does not support .luau files, so rename them to .lua for
		-- compatibility
		for _, luauFile in find(memberBuildPath, "%.luau$") do
			local newName = luauFile:gsub("%.luau$", ".lua")
			run("cp", { "-R", luauFile, newName })
			fs.remove(luauFile)
		end
	end

	return memberBuildPath
end

local function compile(channel: Channel, target: Target)
	local dest = `{project.BUILD_PATH}/plugin`

	if fs.exists(dest) then
		run("rm", { "-rf", dest })
	end
	fs.mkdir(dest)

	local commitHash = run("git", { "rev-parse", "--short", "HEAD" })

	local env = {
		BUILD_VERSION = (wallyToml :: any).package.version,
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

	for _, member in fs.listdir(project.WORKSPACE_PATH) do
		local memberPath = `{project.WORKSPACE_PATH}/{member.name}`

		if fs.type(memberPath) == "dir" then
			local memberBuildPath = compileWorkspaceMember(memberPath, channel, target, env)

			run("mkdir", { "-p", `{dest}/{memberPath}` })
			run("cp", { "-R", `{memberBuildPath}/*`, `{dest}/{memberPath}` })
		end
	end

	if channel == "prod" then
		for _, dir in project.PROD_CONFIG.prunedDirs do
			run("rm", { "-rf", `{dest}/{dir}` })
		end
	end
end

return compile
