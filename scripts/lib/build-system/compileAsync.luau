local fs = require("@lute/fs")
local project = require("@repo/project")

local compileWorkspaceMemberAsync = require("@scripts/lib/build-system/compileWorkspaceMemberAsync")
local run = require("@scripts/lib/run")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = require("@scripts/lib/flipbook-batteries/copyInto")

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
				copyInto(path, context.dest)
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
end

return compileAsync
