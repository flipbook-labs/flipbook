local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local fs = require("@lute/fs")
local project = require("@repo/project")

local compileWorkspaceMemberAsync = require("@scripts/lib/build-system/compileWorkspaceMemberAsync")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = FlipbookBatteries.copyInto
local find = FlipbookBatteries.find
local run = FlipbookBatteries.run

type BuildContext = types.BuildContext

local function compileAsync(context: BuildContext)
	if context.shouldRebuild then
		run("rm", { "-rf", context.dest })
	end
	run("mkdir", { "-p", context.dest })

	run("rojo", {
		"sourcemap",
		project.ROJO_BUILD_PROJECT,
		"-o",
		project.DARKLUA_SOURCEMAP_PATH,
	})

	run("darklua", {
		"process",
		project.SOURCE_PATH,
		context.dest,
	}, {
		env = context.env,
	})

	runBuildGroupAsync({
		name = "🚚 dependencies",
		paths = {
			project.PACKAGES_PATH,
			project.ROBLOX_PACKAGES_PATH,
		},
		context = context,
		step = function(group)
			for _, path in group.paths do
				copyInto(path, `{context.dest}/{path}`)
			end
		end,
	})

	for _, member in fs.listdir(project.WORKSPACE_PATH) do
		local memberPath = `{project.WORKSPACE_PATH}/{member.name}`

		if fs.type(memberPath) == "dir" then
			compileWorkspaceMemberAsync(memberPath, context)
		end
	end

	if context.channel == "prod" then
		for _, dir in project.PROD_CONFIG.prunedDirs do
			run("rm", { "-rf", `{context.dest}/{dir}` })
		end
	end

	if context.target == "rotriever" then
		local dest = `{project.BUILD_PATH}/flipbook-core-rotriever`

		copyInto(context.dest, `{dest}/src`)

		local linkerPath = `{dest}/src/init.lua`
		local linkerSource = `return require(script.workspace["flipbook-core"])`

		fs.remove(`{dest}/src/init.server.luau`)

		local manifestPaths = find(dest, "rotriever.toml")
		if #manifestPaths > 0 then
			local manifestPath = manifestPaths[1]
			print("manifestPath", manifestPath)
			fs.copy(manifestPath, `{dest}/rotriever.toml`)
		end

		local handle = fs.open(linkerPath, "w+")
		fs.write(handle, linkerSource)
	end
end

return compileAsync
