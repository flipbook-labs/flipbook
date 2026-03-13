local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local fs = require("@std/fs")
local path = require("@std/path")

local project = require("@repo/project")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = FlipbookBatteries.copyInto
local run = FlipbookBatteries.run

type BuildContext = types.BuildContext

local function compileWorkspaceMemberAsync(memberPath: path.pathlike, context: BuildContext): path.path
	local memberBuildPath = path.join(memberPath, "build")

	runBuildGroupAsync({
		name = `📦 build {memberPath}`,
		paths = {
			memberPath,
		},
		context = context,
		step = function()
			fs.removedirectory(memberBuildPath, {
				recursive = true,
			})
			fs.createdirectory(memberBuildPath, {
				makeparents = true,
			})

			run("darklua", {
				"process",
				path.join(memberPath, "src"),
				memberBuildPath,
			}, {
				env = context.env,
			})
		end,
	})

	if context.channel == "prod" then
		runBuildGroupAsync({
			name = `✂️ prune {memberPath}`,
			paths = { memberBuildPath },
			context = context,
			step = function()
				for _, pattern in project.PROD_CONFIG.prunedFiles do
					run("find", { memberBuildPath, "-type", "f", "-name", `"{pattern}"`, "-delete" })
				end
			end,
		})
	end

	local relativePath = path.relative(project.REPO_PATH, memberPath)
	local dest = path.join(context.dest, relativePath)

	fs.removedirectory(dest, {
		recursive = true,
	})
	copyInto(memberBuildPath, dest)

	return memberBuildPath
end

return compileWorkspaceMemberAsync
