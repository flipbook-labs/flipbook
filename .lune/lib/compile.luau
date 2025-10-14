local fs = require("@lune/fs")
local project = require("@repo/project")
local serde = require("@lune/serde")
local task = require("@lune/task")

local find = require("./find")
local run = require("./run")
local waitForTasks = require("./waitForTasks")

local wallyToml = serde.decode("toml", fs.readFile("wally.toml"))

type Channel = "prod" | "dev"
type Target = "roblox" | "rotriever"

local function compileWorkspaceMember(
	memberPath: string,
	channel: Channel,
	target: Target,
	env: { [string]: any }
): string
	local startTime = os.clock()

	local memberBuildPath = `{memberPath}/build`
	print(`[{memberPath}] compiling...`)

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

	local tasks: { thread } = {}

	table.insert(
		tasks,
		task.spawn(function()
			print(`[{memberPath}] copying Packages...`)

			local packagesPath = `{memberPath}/Packages`
			fs.copy(packagesPath, `{memberBuildPath}/Packages`)

			print(`[{memberPath}] successfully copied Packages`)
		end)
	)

	table.insert(
		tasks,
		task.spawn(function()
			print(`[{memberPath}] copying RobloxPackages...`)

			local robloxPackagesPath = `{memberPath}/RobloxPackages`
			if fs.isDir(robloxPackagesPath) then
				fs.copy(robloxPackagesPath, `{memberBuildPath}/RobloxPackages`)
			end

			print(`[{memberPath}] successfully copied RobloxPackages`)
		end)
	)

	if channel == "prod" then
		table.insert(
			tasks,
			task.spawn(function()
				print(`[{memberPath}] pruning development files...`)

				for _, pattern in project.PROD_CONFIG.prunedFiles do
					run("find", { memberBuildPath, "-type", "f", "-name", pattern, "-delete" })
				end

				print(`[{memberPath}] successfully pruned development files`)
			end)
		)
	end

	if target == "rotriever" then
		table.insert(
			tasks,
			task.spawn(function()
				print(`[{memberPath}] renaming .luau files for Rotriever compatibility...`)

				-- Rotriever does not support .luau files, so rename them to .lua for
				-- compatibility
				for _, luauFile in find(memberBuildPath, "%.luau$") do
					local newName = luauFile:gsub("%.luau$", ".lua")
					fs.move(luauFile, newName)
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

	print("compiling workspace members...")
	local tasks: { thread } = {}
	for _, member in fs.readDir(project.WORKSPACE_PATH) do
		local memberPath = `{project.WORKSPACE_PATH}/{member}`

		if fs.isDir(memberPath) then
			table.insert(
				tasks,
				task.spawn(function()
					local memberBuildPath = compileWorkspaceMember(memberPath, channel, target, env)
					fs.copy(memberBuildPath, `{dest}/{memberPath}`)
				end)
			)
		end
	end

	waitForTasks(tasks)

	print("successfully compiled workspace members")

	if channel == "prod" then
		for _, dir in project.PROD_CONFIG.prunedDirs do
			fs.removeDir(`{dest}/{dir}`)
		end
	end
end

return compile
