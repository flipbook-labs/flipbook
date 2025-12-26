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

local function compileWorkspaceMemberAsync(memberPath: string, context: BuildContext): string
	local memberBuildPath = `{memberPath}/build`

	runBuildGroupAsync({
		name = `📦 build {memberPath}`,
		paths = {
			memberPath,
		},
		context = context,
		step = function()
			rmdir(memberBuildPath)
			copyInto(`{memberPath}/src`, memberBuildPath)

			run("darklua", {
				"process",
				`{memberPath}/src`,
				memberBuildPath,
			}, {
				env = context.env,
			})
		end,
	})

	runBuildGroupAsync({
		name = `📖 docs`,
		paths = {
			memberPath,
		},
		context = context,
		step = function()
			-- Turn all .md files into .txt so Rojo will sync them as StringValues
			for _, mdFile in find(memberBuildPath, "%.md(x?)$") do
				local newName = mdFile:gsub("%.md$", ".txt")
				fs.copy(mdFile, newName)
				fs.remove(mdFile)
			end
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

	local dest = `{context.dest}/{memberPath}`

	rmdir(dest)
	mkdir(dest)
	copyInto(memberBuildPath, dest)

	return memberBuildPath
end

return compileWorkspaceMemberAsync
