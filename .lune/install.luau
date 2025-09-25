local fs = require("@lune/fs")

local run = require("./lib/run")

local function find(rootPath: string, namePattern: string): { string }
	local files = {}
	local function search(path: string)
		if fs.isFile(path) then
			return
		end

		for _, file in fs.readDir(path) do
			local fullPath = `{path}/{file}`

			if fs.isFile(fullPath) then
				if file:match(namePattern) then
					table.insert(files, fullPath)
				end
			else
				search(fullPath)
			end
		end
	end
	search(rootPath)

	return files
end

local function findAndReplace(filePath: string, match: string, replacement: string)
	local content = fs.readFile(filePath)
	content = content:gsub(match, replacement)
	fs.writeFile(filePath, content)
end

-- local function installPackageFromRepo(
-- 	packageName: string,
-- 	repo: string,
-- 	rev: string,
-- 	extraSteps: ((packagePath: string) -> ())?
-- )
-- 	local packagePath = `build/{packageName}`

-- 	run("rm", { "-rf", packagePath })
-- 	run("rm", { "-rf", `{packagePath}.lua` })
-- 	run("git", { "clone", repo, packagePath })
-- 	run("git", { "checkout", rev }, {
-- 		cwd = packagePath,
-- 	})

-- 	if extraSteps then
-- 		extraSteps(packagePath)
-- 	end
-- end

local function installWallyPackages()
	local function installPackagesForProject(projectPath: string?)
		print("installing packages for", projectPath)

		run("wally", { "install" }, {
			cwd = projectPath,
		})

		local rojoProject = if projectPath then "default.project.json" else "build.project.json"

		run("rojo", { "sourcemap", rojoProject, "-o", "sourcemap.json" }, {
			cwd = projectPath,
		})

		-- For some reason the default stdio of "inherit" results in WPT hanging
		-- indefinitely. Since we don't need the output in this case, we change to a
		-- stdio that won't hang
		run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" }, {
			stdio = "forward",
			cwd = projectPath,
		})
	end

	-- installPackageFromRepo("Storyteller", "https://github.com/flipbook-labs/storyteller", "main", function(packagePath)
	-- 	run("lune", { "run", "install" }, {
	-- 		cwd = packagePath,
	-- 		stdio = "none",
	-- 	})
	-- 	run("lune", { "run", "build" }, {
	-- 		cwd = packagePath,
	-- 	})
	-- 	run("cp", { "-R", `{packagePath}/dist`, "Packages/Storyteller" })
	-- end)

	-- installPackageFromRepo(
	-- 	"ModuleLoader",
	-- 	"https://github.com/flipbook-labs/module-loader",
	-- 	"roblox-internal",
	-- 	function(packagePath)
	-- 		run("lune", { "run", "install" }, {
	-- 			cwd = packagePath,
	-- 			stdio = "none",
	-- 		})
	-- 		run("lune", { "run", "build" }, {
	-- 			cwd = packagePath,
	-- 		})
	-- 		run("cp", { "-R", `{packagePath}/dist`, "Packages/ModuleLoader" })
	-- 	end
	-- )

	for _, member in fs.readDir("workspace") do
		local memberPath = `workspace/{member}`
		if fs.isDir(memberPath) then
			installPackagesForProject(memberPath)
		end
	end

	installPackagesForProject()
end

local function installRobloxPackages()
	run("roblox-packages", { "install", "RobloxPackagesTmp", "--version", "0.690.0.6900721" })

	local dest = "workspace/flipbook-core/RobloxPackages"
	if fs.isDir(dest) then
		fs.removeDir(dest)
	end
	fs.move("RobloxPackagesTmp/Packages", dest)
	fs.removeDir("RobloxPackagesTmp")

	-- Patch React and RoactCompat dependencies to use ours
	for _, name in { "React", "RoactCompat", "Roact" } do
		local linkers = find(dest, `^{name}%..*`)

		for _, linker in linkers do
			-- All Roact linkers in RobloxPackages point to Roblox's
			-- RoactCompat, so we need to update them to point to ours instead.
			if name == "Roact" then
				name = "RoactCompat"
			end

			findAndReplace(
				linker,
				"local PackageIndex = .*_Index",
				'local Root = script:FindFirstAncestor("RobloxPackages")'
			)
			findAndReplace(
				linker,
				"local Package = require%(.*%)",
				`local Package = require(Root.Parent.Packages.{name})`
			)
		end
	end
end

local function installRbxasset()
	local packagesPath = "LunePackages"

	run("rm", { "-rf", packagesPath })
	run("mkdir", { "-p", packagesPath })

	run("curl", { "-LO", "https://github.com/Roblox/rbxasset/releases/download/v0.2.0/rbxasset.zip" }, {
		cwd = packagesPath,
	})

	run("unzip", { "rbxasset.zip" }, {
		cwd = packagesPath,
	})

	run("rm", { "-rf", "rbxasset.zip" }, {
		cwd = packagesPath,
	})
end

local function pruneDevelopmentFiles()
	-- Prune any third-party tests or stories that may have slipped through
	local prunedFiles = {
		"*.spec.lua*",
		"*.story.lua*",
		"*.storybook.lua*",
	}
	for _, path in { "Packages", "workspace/flipbook-core/RobloxPackages" } do
		for _, pattern in prunedFiles do
			run("find", { path, "-type", "f", "-name", pattern, "-delete" })
		end
	end
end

installRobloxPackages()
installWallyPackages()
installRbxasset()
pruneDevelopmentFiles()
