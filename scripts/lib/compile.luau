local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local fs = require("@lute/fs")
local process = require("@lute/process")
local toml = require("@luaupkg/batteries/toml")

local project = require("@repo/project")
local waitForTasks = require("./waitForTasks")

local run = FlipbookBatteries.run
local find = FlipbookBatteries.find

type Channel = "prod" | "dev"
type Target = "roblox" | "rotriever"

local function readWallyManifest()
	local wallyTomlHandle = fs.open("wally.toml", "r")
	local contents = fs.read(wallyTomlHandle)
	fs.close(wallyTomlHandle)
	return toml.deserialize(contents)
end

-- Lute's `task.spawn` doesn't actually seem to return a thread. When the return
-- value would get to `coroutine.status` it would fail with the following:
-- "invalid argument #1 to 'status' (thread expected, got function)"
local function taskSpawn(callback: () -> ()): thread
	local thread = coroutine.create(callback)
	coroutine.resume(thread)
	return thread
end

local function compileWorkspaceMember(
	memberPath: string,
	channel: Channel,
	target: Target,
	env: { [string]: string }
): string
	local startTime = os.clock()

	local memberBuildPath = `{memberPath}/build`
	print(`[{memberPath}] compiling...`)

	run("rm", { "-rf", memberBuildPath })
	run("mkdir", { "-p", memberBuildPath })

	run("darklua", {
		"process",
		`{memberPath}/src`,
		memberBuildPath,
	}, {
		env = env,
	})

	local tasks: { thread } = {}

	if channel == "prod" then
		table.insert(
			tasks,
			taskSpawn(function()
				print(`[{memberPath}] pruning development files...`)

				for _, pattern in project.PROD_CONFIG.prunedFiles do
					run("find", { memberBuildPath, "-type", "f", "-name", `"{pattern}"`, "-delete" })
				end

				print(`[{memberPath}] successfully pruned development files`)
			end)
		)
	end

	if target == "rotriever" then
		table.insert(
			tasks,
			taskSpawn(function()
				print(`[{memberPath}] renaming .luau files for Rotriever compatibility...`)

				-- Rotriever does not support .luau files, so rename them to .lua for
				-- compatibility
				for _, luauFile in find(memberBuildPath, "%.luau$") do
					local newName = luauFile:gsub("%.luau$", ".lua")
					run("cp", { "-R", luauFile, newName })
					fs.remove(luauFile)
				end

				print(`[{memberPath}] successfully renamed files for Rotriever`)
			end)
		)
	end

	waitForTasks(tasks)

	print(`[{memberPath}] completed in {("%.2f"):format(os.clock() - startTime)}s`)

	return memberBuildPath
end

local function compile(channel: Channel, target: Target)
	local dest = `{project.BUILD_PATH}/plugin`

	run("rm", { "-rf", dest })
	run("mkdir", { "-p", dest })

	local commitHash = run("git", { "rev-parse", "--short", "HEAD" }, {
		stdio = "default",
	})
	assert(commitHash ~= nil and commitHash ~= "", "commit hash is empty")

	local wallyToml = readWallyManifest()

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

		if member.type == "dir" then
			table.insert(
				tasks,
				taskSpawn(function()
					local memberBuildPath = compileWorkspaceMember(memberPath, channel, target, env)
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
end

return compile
