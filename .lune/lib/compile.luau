local fs = require("@lune/fs")
local process = require("@lune/process")
local project = require("@repo/project")
local serde = require("@lune/serde")

local find = require("./find")
local run = require("./run")

local wallyToml = serde.decode("toml", fs.readFile("wally.toml"))

type Channel = "prod" | "dev"
type Target = "roblox" | "rotriever"

local function compileWorkspaceMember(
	memberPath: string,
	channel: Channel,
	target: Target,
	env: { [string]: any }
): string
	local memberBuildPath = `{memberPath}/build`

	if fs.isDir(memberBuildPath) then
		fs.removeDir(memberBuildPath)
	end
	fs.writeDir(memberBuildPath)

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
	if fs.isDir(robloxPackagesPath) then
		run("cp", { "-R", robloxPackagesPath, `{memberBuildPath}/RobloxPackages` })
	end

	if channel == "prod" then
		for _, pattern in project.PROD_CONFIG.prunedFiles do
			run("find", { memberBuildPath, "-type", "f", "-name", pattern, "-delete" })
		end
	end

	if target == "rotriever" then
		-- Rotriever does not support .luau files, so rename them to .lua for
		-- compatibility
		for _, luauFile in find(memberBuildPath, "%.luau$") do
			local newName = luauFile:gsub("%.luau$", ".lua")
			fs.move(luauFile, newName)
		end
	end

	return memberBuildPath
end

local function compile(channel: Channel, target: Target)
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
		BASE_URL = process.env.BASE_URL,
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

	run("cp", { "-R", "RobloxPackages", `{dest}/RobloxPackages` })

	for _, member in fs.readDir(project.WORKSPACE_PATH) do
		local memberPath = `{project.WORKSPACE_PATH}/{member}`

		if fs.isDir(memberPath) then
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
