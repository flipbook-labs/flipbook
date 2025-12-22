local fs = require("@lute/fs")
local process = require("@lute/process")
local project = require("@repo/project")
local toml = require("@batteries/toml")

local compileWorkspaceMemberAsync = require("@scripts/lib/build-system/compileWorkspaceMemberAsync")
local hashDir = require("@scripts/lib/build-system/hashDir")
local readBuildCacheAsync = require("@scripts/lib/build-system/readBuildCacheAsync")
local run = require("@scripts/lib/run")
local waitForTasks = require("@scripts/lib/waitForTasks")
local writeBuildCacheAsync = require("@scripts/lib/build-system/writeBuildCacheAsync")

local wallyToml = toml.deserialize(fs.readfiletostring("wally.toml"))

type Channel = "prod" | "dev"
type Target = "roblox" | "rotriever"

-- Lute's `task.spawn` doesn't actually seem to return a thread. When the return
-- value would get to `coroutine.status` it would fail with the following:
-- "invalid argument #1 to 'status' (thread expected, got function)"
local function taskSpawn(callback: () -> ()): thread
	local thread = coroutine.create(callback)
	coroutine.resume(thread)
	return thread
end

local function compileAsync(channel: Channel, target: Target)
	local dest = `{project.BUILD_PATH}/plugin`

	run("rm", { "-rf", dest })
	run("mkdir", { "-p", dest })

	local buildCache = readBuildCacheAsync()

	local commitHash = run("git", { "rev-parse", "--short", "HEAD" }, {
		stdio = "default",
	})
	assert(commitHash ~= nil and commitHash ~= "", "commit hash is empty")

	local env = {
		BUILD_VERSION = (wallyToml :: any).package.version,
		BUILD_CHANNEL = if channel == "prod" then "production" else "development",
		BUILD_HASH = commitHash,
		BASE_URL = process.env.BASE_URL,
	}

	for k, v in env do
		print(`_G.{k} = {v}`)
	end

	run("rojo", {
		"sourcemap",
		project.ROJO_BUILD_PROJECT,
		"-o",
		project.DARKLUA_SOURCEMAP_PATH,
	})

	run("darklua", {
		"process",
		project.SOURCE_PATH,
		dest,
	}, {
		env = env,
	})

	print("copying dependencies...")
	for _, path in { project.PACKAGES_PATH, project.ROBLOX_PACKAGES_PATH } do
		run("cp", { "-R", path, dest })
	end

	print("compiling workspace members...")
	local tasks: { thread } = {}
	for _, member in fs.listdir(project.WORKSPACE_PATH) do
		local memberPath = `{project.WORKSPACE_PATH}/{member.name}`

		if fs.type(memberPath) ~= "dir" then
			continue
		end

		print("MEMBER", memberPath)

		local hash = hashDir(memberPath)

		print("HASH", memberPath, hash)

		if hash == buildCache.hashes[memberPath] then
			continue
		else
			buildCache.hashes[memberPath] = hash
		end

		if member.type == "dir" then
			table.insert(
				tasks,
				taskSpawn(function()
					local memberBuildPath = compileWorkspaceMemberAsync(memberPath, channel, target, env)
					run("mkdir", { "-p", `{dest}/{memberPath}` })
					run("cp", { "-R", `{memberBuildPath}/**`, `{dest}/{memberPath}` })
				end)
			)
		end
	end

	waitForTasks(tasks)

	print("successfully compiled workspace members")

	if channel == "prod" then
		for _, dir in project.PROD_CONFIG.prunedDirs do
			run("rm", { "-rf", `{dest}/{dir}` })
		end
	end

	writeBuildCacheAsync(buildCache)
end

return compileAsync
