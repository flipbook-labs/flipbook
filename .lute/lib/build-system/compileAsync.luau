local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local fs = require("@std/fs")
local path = require("@std/path")

local compileWorkspaceMemberAsync = require("@scripts/lib/build-system/compileWorkspaceMemberAsync")
local packToRbxm = require("@scripts/lib/packToRbxm")
local project = require("@repo/project")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local runCodeModsAsync = require("@scripts/lib/build-system/runCodeModsAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = FlipbookBatteries.copyInto
local find = FlipbookBatteries.find
local run = FlipbookBatteries.run

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

	-- The code mods look up which instance each file becomes in this
	-- sourcemap of the source tree. The build output keeps the same layout.
	run("rojo", {
		"sourcemap",
		project.SOURCEMAP_PROJECT_PATH,
		"-o",
		project.BUILD_SOURCEMAP_PATH,
	})

	-- `src/` sits at the root of the output, beside the dependencies and
	-- workspace members copied in below. The mods run only on the files that
	-- came from `src/`, since the workspace members run them in their own step.
	local sourceCopies: { path.Path } = {}
	for _, entry in fs.listDirectory(project.SOURCE_PATH) do
		local dest = path.join(context.dest, entry.name)
		copyInto(path.join(project.SOURCE_PATH, entry.name), dest)
		table.insert(sourceCopies, dest)
	end

	runCodeModsAsync({
		sourceFolder = project.SOURCE_PATH,
		buildFolder = context.dest,
		paths = sourceCopies,
		context = context,
	})

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

	for _, member in fs.listDirectory(project.WORKSPACE_PATH) do
		local memberPath = path.join(project.WORKSPACE_PATH, member.name)

		if fs.type(memberPath) == "dir" then
			compileWorkspaceMemberAsync(memberPath, context)
		end
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
