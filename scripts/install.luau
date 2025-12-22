local fs = require("@lute/fs")
local process = require("@lute/process")

local project = require("@repo/project")

local LUAU_PACKAGES_PATH = "LuauPackages"

-- Install flipbook-batteries first because it has a lot of the useful functions
-- we need when installing the rest of our packages
do
	local function installFlipbookBatteries()
		local res = process.run({
			"curl",
			"-LO",
			"https://github.com/flipbook-labs/flipbook-batteries/releases/download/v0.3.0/flipbook-batteries.zip",
		}, {
			cwd = LUAU_PACKAGES_PATH,
		})
		assert(res.ok, res.stderr)

		res = process.run({
			"unzip",
			"flipbook-batteries.zip",
		}, {
			cwd = LUAU_PACKAGES_PATH,
		})
		assert(res.ok, res.stderr)

		res = process.run({ "rm", "-rf", `{LUAU_PACKAGES_PATH}/flipbook-batteries.zip` }, {
			stdio = "inherit",
		})
		assert(res.ok, res.stderr)
	end

	local res = process.run({ "rm", "-rf", LUAU_PACKAGES_PATH }, {
		stdio = "inherit",
	})
	assert(res.ok, res.stderr)

	res = process.run({ "mkdir", LUAU_PACKAGES_PATH })
	assert(res.ok, res.stderr)

	installFlipbookBatteries()
end

do
	local FlipbookBatteries = require("@luaupkg/flipbook-batteries")

	local run = FlipbookBatteries.run
	local find = FlipbookBatteries.find
	local findAndReplace = FlipbookBatteries.findAndReplace

	local function installWallyPackages()
		run("wally", { "install" })
		run("rojo", { "sourcemap", project.ROJO_BUILD_PROJECT, "-o", "sourcemap.json" })
		run("wally-package-types", { "--sourcemap", "sourcemap.json", project.PACKAGES_PATH })
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
			"pp.luau",
			"richterm.luau",
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

	installRobloxPackages()
	installWallyPackages()
	installLuteBatteries()
	installRbxasset()
	pruneDevelopmentFiles()
end
