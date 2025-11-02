local fs = require("@lute/fs")
local project = require("@repo/project")

local find = require("./lib/find")
local run = require("./lib/run")

local LUAU_PACKAGES_PATH = "LuauPackages"

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
		"0.697.0.6970925",
		"-d",
		"Foundation",
		"-d",
		"Signals",
		"-d",
		"SignalsReact",

		-- These are only included so the above dependencies work as expected.
		-- It seems like roblox-packages has a bug with its dependency
		-- resolution that is resulting in over-pruning
		"-d",
		"Promise",
		"-d",
		"Dash",
	})

	local dest = `{project.WORKSPACE_PATH}/flipbook-core/RobloxPackages`
	if fs.exists(dest) and fs.type(dest) == "dir" then
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

local function installLuteBatteries()
	local commit = "7b4e269"
	local batteries = {
		"cli.luau",
		"toml.luau",
	}

	local dest = `{LUAU_PACKAGES_PATH}/batteries`
	run("mkdir", { "-p", dest })
	for _, battery in batteries do
		run("curl", { "-LO", `https://raw.githubusercontent.com/luau-lang/lute/{commit}/batteries/{battery}` }, {
			cwd = dest,
		})
	end
end

local function installRbxasset()
	run("rm", { "-rf", LUAU_PACKAGES_PATH })
	run("mkdir", { "-p", LUAU_PACKAGES_PATH })

	run("curl", { "-LO", "https://github.com/Roblox/rbxasset/releases/download/v0.2.0/rbxasset.zip" }, {
		cwd = LUAU_PACKAGES_PATH,
	})

	run("unzip", { "rbxasset.zip" }, {
		cwd = LUAU_PACKAGES_PATH,
	})

	fs.remove(`{LUAU_PACKAGES_PATH}/rbxasset.zip`)
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
installLuteBatteries()
pruneDevelopmentFiles()
