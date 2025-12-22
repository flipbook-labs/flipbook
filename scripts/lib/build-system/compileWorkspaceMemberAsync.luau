local fs = require("@lute/fs")

local find = require("@scripts/lib/find")
local project = require("@repo/project")
local run = require("@scripts/lib/run")
local types = require("@scripts/lib/build-system/types")
local waitForTasks = require("@scripts/lib/waitForTasks")

type BuildContext = types.BuildContext

-- Lute's `task.spawn` doesn't actually seem to return a thread. When the return
-- value would get to `coroutine.status` it would fail with the following:
-- "invalid argument #1 to 'status' (thread expected, got function)"
local function taskSpawn(callback: () -> ()): thread
	local thread = coroutine.create(callback)
	coroutine.resume(thread)
	return thread
end

local function compileWorkspaceMemberAsync(memberPath: string, context: BuildContext): string
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
		env = context.env,
	})

	local tasks: { thread } = {}

	if context.channel == "prod" then
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

	if context.target == "rotriever" then
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

return compileWorkspaceMemberAsync
