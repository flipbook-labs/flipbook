local fs = require("@lute/fs")
local project = require("@repo/project")

local run = require("./lib/run")

local function find(rootPath: string, namePattern: string): { string }
	local files = {}
	local function search(path: string)
		if fs.stat(path).type == "file" then
			return
		end

		for _, file in fs.listdir(path) do
			local fullPath = `{path}/{file.name}`

			if file.type == "file" then
				if file.name:match(namePattern) then
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
	local content = fs.readfiletostring(filePath)
	content = content:gsub(match, replacement)
	fs.writestringtofile(filePath, content)
end

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

		run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" }, {
			cwd = projectPath,
		})
	end

	for _, member in fs.listdir(project.WORKSPACE_PATH) do
		if member.type == "dir" then
			installPackagesForProject(`{project.WORKSPACE_PATH}/{member.name}`)
		end
	end
end

local function installRobloxPackages()
	run("roblox-packages", {
		"install",
		"RobloxPackagesTmp",
		"--version",
		"0.693.0.6930961",
		"-d",
		"Foundation",
		"-d",
		"LuauPolyfill",
		"-d",
		"Signals",
		"-d",
		"SignalsReact",
	})

	local dest = `{project.WORKSPACE_PATH}/flipbook-core/RobloxPackages`
	if fs.exists(dest) and fs.stat(dest).type == "dir" then
		run("rm", { "-rf", dest })
	end
	run("mv", { "RobloxPackagesTmp/Packages", dest })
	run("rm", { "-rf", "RobloxPackagesTmp" })

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
	for _, path in { `{project.WORKSPACE_PATH}/**/Packages`, `{project.WORKSPACE_PATH}/**/RobloxPackages` } do
		for _, pattern in prunedFiles do
			run("find", { path, "-type", "f", "-name", `"{pattern}"`, "-delete" })
		end
	end
end

installRobloxPackages()
installWallyPackages()
installRbxasset()
pruneDevelopmentFiles()
