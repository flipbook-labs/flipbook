local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local fs = require("@std/fs")
local path = require("@std/path")

local compileWorkspaceMemberAsync = require("@scripts/lib/build-system/compileWorkspaceMemberAsync")
local packToRbxm = require("@scripts/lib/packToRbxm")
local project = require("@repo/project")
local runBuildGroupAsync = require("@scripts/lib/build-system/runBuildGroupAsync")
local types = require("@scripts/lib/build-system/types")

local copyInto = FlipbookBatteries.copyInto
local find = FlipbookBatteries.find
local run = FlipbookBatteries.run

type BuildContext = types.BuildContext

local function compileAsync(context: BuildContext)
	if context.shouldRebuild then
		fs.removedirectory(context.dest, {
			recursive = true,
		})
	end
	fs.createdirectory(context.dest, {
		makeparents = true,
	})

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
			for _, filePath in group.paths do
				local relativePath = path.relative(project.REPO_PATH, filePath)
				copyInto(filePath, path.join(context.dest, relativePath))
			end
		end,
	})

	for _, member in fs.listdirectory(project.WORKSPACE_PATH) do
		local memberPath = path.join(project.WORKSPACE_PATH, member.name)

		if fs.type(memberPath) == "dir" then
			compileWorkspaceMemberAsync(memberPath, context)
		end
	end

	if context.channel == "prod" then
		for _, dir in project.PROD_CONFIG.prunedDirs do
			local relativePath = path.relative(project.REPO_PATH, dir)

			fs.removedirectory(path.join(context.dest, relativePath), {
				recursive = true,
			})
		end
	end

	if context.target == "rotriever" then
		local dest = path.join(project.BUILD_PATH, "flipbook-core-rotriever")

		if context.shouldRebuild then
			fs.removedirectory(dest, {
				recursive = true,
			})
		end

		copyInto(context.dest, path.join(dest, "src"))

		fs.remove(path.join(dest, "src/init.server.luau"))

		local manifestPaths = find(dest, "rotriever.toml")
		if #manifestPaths > 0 then
			local manifestPath = manifestPaths[1]
			fs.copy(manifestPath, path.join(dest, "rotriever.toml"))
		end

		-- Bundle up the gigantic dependency bundles into rbxms to alleviate
		-- path length limit issues that crop up when consuming internally
		for _, relativePackagesPath in { project.PACKAGES_PATH, project.ROBLOX_PACKAGES_PATH } do
			local packagesPath = path.resolve(path.join(dest, "src", relativePackagesPath))

			packToRbxm(packagesPath)

			fs.removedirectory(packagesPath, {
				recursive = true,
			})
		end

		local linkerPath = path.join(dest, "src/init.lua")
		local linkerSource = `return require(script.workspace["flipbook-core"])`
		fs.writestringtofile(linkerPath, linkerSource)

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
