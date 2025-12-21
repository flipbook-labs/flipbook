local fs = require("@lute/fs")
local json = require("@std/json")
local project = require("@repo/project")

local find = require("./lib/find")
local findAndReplace = require("./lib/findAndReplace")
local run = require("./lib/run")

local LUAU_PACKAGES_PATH = "LuauPackages"

-- LuauLog is written with string requires which are not yet supported by
-- ModuleLoader. To allow us to still use LuauLog, this function patches it with
-- darklua to resolve the string requires to Roblox ones
local function patchLuauLog()
	local packageRoot = find(`{project.PACKAGES_PATH}/_Index`, "luaulog")[1]

	local darkluaConfig = {
		process = {
			{
				rule = "convert_require",
				current = {
					name = "luau",
				},
				target = {
					name = "roblox",
					rojo_sourcemap = "./sourcemap.json",
					indexing_style = "property",
				},
			},
		},
	}

	local handle = fs.open(`{packageRoot}/.darklua.json`, "w+")
	fs.write(handle, json.serialize(darkluaConfig, true))

	run("rojo", { "sourcemap", "-o", "sourcemap.json" }, {
		cwd = packageRoot,
	})

	run("darklua", { "process", "src", "src" }, {
		cwd = packageRoot,
	})
end

local function installWallyPackages()
	run("wally", { "install" })
	run("rojo", { "sourcemap", project.ROJO_BUILD_PROJECT, "-o", "sourcemap.json" })
	run("wally-package-types", { "--sourcemap", "sourcemap.json", project.PACKAGES_PATH })

	if fs.exists(`{project.PACKAGES_PATH}/Log.lua`) then
		patchLuauLog()
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

	local dest = project.ROBLOX_PACKAGES_PATH
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
	local commit = "7f5ccf7"
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
	for _, path in { project.PACKAGES_PATH, project.ROBLOX_PACKAGES_PATH } do
		for _, pattern in prunedFiles do
			run("find", { path, "-type", "f", "-name", `"{pattern}"`, "-delete" })
		end
	end
end

run("lute", { "setup" })

installRobloxPackages()
installWallyPackages()
installRbxasset()
installLuteBatteries()
pruneDevelopmentFiles()
