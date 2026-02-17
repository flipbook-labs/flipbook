local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local fs = require("@lute/fs")

local project = require("@repo/project")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = FlipbookBatteries.copyInto
local find = FlipbookBatteries.find
local mkdir = FlipbookBatteries.mkdir
local rmdir = FlipbookBatteries.rmdir
local run = FlipbookBatteries.run

type BuildContext = types.BuildContext

local function compileWorkspaceMemberAsync(memberPath: string, context: BuildContext): string?
	local memberBuildPath = `{context.dest}/{memberPath}`

	rmdir(memberBuildPath)
	mkdir(memberBuildPath)

	if context.channel == "prod" then
		for _, dir in project.PROD_CONFIG.prunedDirs do
			if memberPath:match(dir) then
				return nil
			end
		end
	end

	runBuildGroupAsync({
		name = `📦 build {memberPath}`,
		paths = {
			memberPath,
		},
		context = context,
		step = function()
			run("rm", { "-rf", memberBuildPath })

			copyInto(memberPath, memberBuildPath)

			run("darklua", {
				"process",
				`{memberBuildPath}/src`,
				`{memberBuildPath}/src`,
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

	if context.target == "rotriever" then
		runBuildGroupAsync({
			name = `🐶 rotriever compat {memberPath}`,
			paths = { memberBuildPath },
			context = context,
			step = function()
				-- Rotriever does not support .luau files, so rename
				-- them to .lua for compatibility
				for _, luauFile in find(memberBuildPath, "%.luau$") do
					local newName = luauFile:gsub("%.luau$", ".lua")
					fs.copy(luauFile, newName)
					fs.remove(luauFile)
				end
			end,
		})
	end

	return memberBuildPath
end

return compileWorkspaceMemberAsync
