local fs = require("@lute/fs")
local project = require("@repo/project")

local compileWorkspaceMemberAsync = require("@scripts/lib/build-system/compileWorkspaceMemberAsync")
local hashPath = require("@scripts/lib/build-system/hashPath")
local readBuildCacheAsync = require("@scripts/lib/build-system/readBuildCacheAsync")
local run = require("@scripts/lib/run")
local types = require("@scripts/lib/build-system/types")
local waitForTasks = require("@scripts/lib/waitForTasks")
local writeBuildCacheAsync = require("@scripts/lib/build-system/writeBuildCacheAsync")

type BuildContext = types.BuildContext

-- Lute's `task.spawn` doesn't actually seem to return a thread. When the return
-- value would get to `coroutine.status` it would fail with the following:
-- "invalid argument #1 to 'status' (thread expected, got function)"
local function taskSpawn(callback: () -> ()): thread
	local thread = coroutine.create(callback)
	coroutine.resume(thread)
	return thread
end

local function compileAsync(context: BuildContext)
	local dest = `{project.BUILD_PATH}/plugin`

	if context.shouldRebuild then
		run("rm", { "-rf", dest })
	end
	run("mkdir", { "-p", dest })

	local buildCache = readBuildCacheAsync()

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
		env = context.env,
	})

	print("copying dependencies...")
	for _, path in { project.PACKAGES_PATH, project.ROBLOX_PACKAGES_PATH } do
		local hash = hashPath(path)

		if hash == buildCache.hashes[path] and not context.shouldRebuild then
			continue
		else
			buildCache.hashes[path] = hash
		end

		run("cp", { "-R", path, dest })
	end

	print("compiling workspace members...")
	local tasks: { thread } = {}
	for _, member in fs.listdir(project.WORKSPACE_PATH) do
		local memberPath = `{project.WORKSPACE_PATH}/{member.name}`

		if fs.type(memberPath) ~= "dir" then
			continue
		end

		local hash = hashPath(memberPath)

		if hash == buildCache.hashes[memberPath] and not context.shouldRebuild then
			continue
		else
			buildCache.hashes[memberPath] = hash
		end

		if member.type == "dir" then
			table.insert(
				tasks,
				taskSpawn(function()
					local memberBuildPath = compileWorkspaceMemberAsync(memberPath, context)
					run("mkdir", { "-p", `{dest}/{memberPath}` })
					run("cp", { "-R", `{memberBuildPath}/**`, `{dest}/{memberPath}` })
				end)
			)
		end
	end

	waitForTasks(tasks)

	print("successfully compiled workspace members")

	if context.channel == "prod" then
		for _, dir in project.PROD_CONFIG.prunedDirs do
			run("rm", { "-rf", `{dest}/{dir}` })
		end
	end

	writeBuildCacheAsync(buildCache)
end

return compileAsync
