local fs = require("@lute/fs")

local find = require("@scripts/lib/find")
local project = require("@repo/project")
local run = require("@scripts/lib/run")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = require("@scripts/lib/flipbook-batteries/copyInto")
local mkdir = require("@scripts/lib/flipbook-batteries/mkdir")
local rmdir = require("@scripts/lib/flipbook-batteries/rmdir")

type BuildContext = types.BuildContext

local function compileWorkspaceMemberAsync(memberPath: string, context: BuildContext): string
	local memberBuildPath = `{memberPath}/build`

	runBuildGroupAsync({
		name = `🏗️ build {memberBuildPath}`,
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
					run("cp", { "-R", luauFile, newName })
					fs.remove(luauFile)
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
