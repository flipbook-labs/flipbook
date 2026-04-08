local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local fs = require("@std/fs")
local path = require("@std/path")

local project = require("@repo/project")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = FlipbookBatteries.copyInto
local run = FlipbookBatteries.run

type BuildContext = types.BuildContext

local function compileWorkspaceMemberAsync(memberPath: path.Pathlike, context: BuildContext): path.Path
	local relativeMemberPath = path.relative(project.REPO_PATH, memberPath)
	local memberBuildPath = path.join(memberPath, "build")

	runBuildGroupAsync({
		name = `📦 build {relativeMemberPath}`,
		paths = {
			memberPath,
		},
		context = context,
		step = function()
			fs.removeDirectory(memberBuildPath, {
				recursive = true,
			})
			fs.createDirectory(memberBuildPath, {
				makeParents = true,
			})

			run("darklua", {
				"process",
				path.join(relativeMemberPath, "src"),
				memberBuildPath,
			}, {
				env = context.env,
			})
		end,
	})

	if context.channel == "prod" then
		runBuildGroupAsync({
			name = `✂️ prune {relativeMemberPath}`,
			paths = { memberBuildPath },
			context = context,
			step = function()
				for _, pattern in project.PROD_CONFIG.prunedFiles do
					run("find", { memberBuildPath, "-type", "f", "-name", `"{pattern}"`, "-delete" })
				end
			end,
		})
	end

	local dest = path.join(context.dest, relativeMemberPath)

	fs.removeDirectory(dest, {
		recursive = true,
	})
	copyInto(memberBuildPath, dest)

	return memberBuildPath
end

return compileWorkspaceMemberAsync
