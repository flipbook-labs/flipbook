local FlipbookBatteries = require("@luaupkg/flipbook-batteries")

local project = require("@repo/project")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = FlipbookBatteries.copyInto
local mkdir = FlipbookBatteries.mkdir
local rmdir = FlipbookBatteries.rmdir
local run = FlipbookBatteries.run

type BuildContext = types.BuildContext

local function compileWorkspaceMemberAsync(memberPath: string, context: BuildContext): string
	local memberBuildPath = `{memberPath}/build`

	runBuildGroupAsync({
		name = `📦 build {memberPath}`,
		paths = {
			memberPath,
		},
		context = context,
		step = function()
			run("rm", { "-rf", memberBuildPath })
			run("mkdir", { "-p", memberBuildPath })

			run("darklua", {
				"process",
				`{memberPath}/src`,
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

	local dest = `{context.dest}/{memberPath}`

	rmdir(dest)
	mkdir(dest)
	copyInto(memberBuildPath, dest)

	return memberBuildPath
end

return compileWorkspaceMemberAsync
