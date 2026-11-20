local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local fs = require("@std/fs")
local path = require("@std/path")

local compileWorkspaceMemberAsync = require("@scripts/lib/build-system/compileWorkspaceMemberAsync")
local createRewriterAsync = require("@scripts/lib/build-system/createRewriterAsync")
local packToRbxm = require("@scripts/lib/packToRbxm")
local project = require("@repo/project")
local rewriteLuau = require("@scripts/lib/build-system/rewriteLuau")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = FlipbookBatteries.copyInto
local find = FlipbookBatteries.find

type BuildContext = types.BuildContext

local function compileAsync(context: BuildContext)
	if context.shouldRebuild then
		fs.removeDirectory(context.dest, {
			recursive = true,
		})
	end
	fs.createDirectory(context.dest, {
		makeParents = true,
	})

	local rewriter = createRewriterAsync(context)
	rewriteLuau.rewriteFolder(rewriter, project.SOURCE_PATH, context.dest)

	runBuildGroupAsync({
		name = "🚚 dependencies",
		paths = {
			project.PACKAGES_PATH,
			project.ROBLOX_PACKAGES_PATH,
		},
		context = context,
		step = function(group)
			for _, filePath in group.paths do
				local relativePath = path.relative(project.REPO_PATH, filePath)
				copyInto(filePath, path.join(context.dest, relativePath))
			end
		end,
	})

	for _, memberPath in project.WORKSPACE_MEMBER_PATHS do
		compileWorkspaceMemberAsync(memberPath, context, rewriter)
	end

	if context.channel == "prod" or context.channel == "beta" then
		for _, dir in project.PROD_CONFIG.prunedDirs do
			local relativePath = path.relative(project.REPO_PATH, dir)

			fs.removeDirectory(path.join(context.dest, relativePath), {
				recursive = true,
			})
		end
	end

	if context.target == "rotriever" then
		local dest = path.join(project.BUILD_PATH, "flipbook-core-rotriever")

		if context.shouldRebuild then
			fs.removeDirectory(dest, {
				recursive = true,
			})
		end

		copyInto(context.dest, path.join(dest, "src"))

		-- Remove all the runtime code since we're just shipping FlipbookCore
		fs.remove(path.join(dest, "src/EmbeddedClientStarterScript.client.luau"))
		fs.remove(path.join(dest, "src/EmbeddedServerStarterScript.server.luau"))
		fs.remove(path.join(dest, "src/PluginStarterScript.plugin.luau"))

		fs.copy(path.join(project.WORKSPACE_PATH, "flipbook-core/rotriever.toml"), path.join(dest, "rotriever.toml"))

		-- Bundle up the gigantic dependency bundles into rbxms to alleviate
		-- path length limit issues that crop up when consuming internally
		for _, absPackagesPath in { project.PACKAGES_PATH, project.ROBLOX_PACKAGES_PATH } do
			local relPackagesPath = path.relative(project.REPO_PATH, absPackagesPath)
			local packagesPath = path.resolve(path.join(dest, "src", relPackagesPath))

			packToRbxm(packagesPath)

			fs.removeDirectory(packagesPath, {
				recursive = true,
			})
		end

		local linkerPath = path.join(dest, "src/init.lua")
		local linkerSource = `return require(script.workspace["flipbook-core"])`
		fs.writeStringToFile(linkerPath, linkerSource)

		-- Rotriever does not support .luau files, so rename
		-- them to .lua for compatibility
		for _, luauFile in find(dest, "%.luau$") do
			local newName = tostring(luauFile):gsub("%.luau$", ".lua")
			fs.copy(luauFile, newName)
			fs.remove(luauFile)
		end
	end
end

return compileAsync
