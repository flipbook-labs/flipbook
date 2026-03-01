local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@lute/process")

local json = require("@std/json")
local project = require("@repo/project")

-- Install flipbook-batteries first because it has a lot of the useful functions
-- we need when installing the rest of our packages
do
	local function installFlipbookBatteries()
		local fileName = "flipbook-batteries.zip"

		local res = process.run({
			"curl",
			"-LO",
			`https://github.com/flipbook-labs/flipbook-batteries/releases/download/v0.5.0/{fileName}`,
		}, {
			cwd = tostring(project.LUAU_PACKAGES_PATH),
		})
		assert(res.ok, res.stderr)

		res = process.run({
			"unzip",
			fileName,
		}, {
			cwd = tostring(project.LUAU_PACKAGES_PATH),
		})
		assert(res.ok, res.stderr)

		local zipFile = path.join(project.LUAU_PACKAGES_PATH, fileName)

		fs.remove(zipFile)
	end

	fs.removedirectory(project.LUAU_PACKAGES_PATH, {
		recursive = true,
	})
	fs.createdirectory(project.LUAU_PACKAGES_PATH)

	installFlipbookBatteries()
end

do
	local FlipbookBatteries = require("@luaupkg/flipbook-batteries")

	local run = FlipbookBatteries.run
	local find = FlipbookBatteries.find
	local findAndReplace = FlipbookBatteries.findAndReplace

	-- LuauLog is written with string requires which are not yet supported by
	-- ModuleLoader. To allow us to still use LuauLog, this function patches it with
	-- darklua to resolve the string requires to Roblox ones
	local function patchLuauLog()
		local packageRoot = find(path.join(project.PACKAGES_PATH, "_Index"), "^luaulog$")[1]

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

		local darkluaConfigPath = path.join(packageRoot, ".darklua.json")
		fs.writestringtofile(darkluaConfigPath, json.serialize(darkluaConfig, true))

		run("rojo", { "sourcemap", "-o", "sourcemap.json" }, {
			cwd = packageRoot,
		})

		run("darklua", { "process", "src", "src" }, {
			cwd = packageRoot,
		})
	end

	local function installWallyPackages()
		run("wally", { "install" })
		run("rojo", { "sourcemap", tostring(project.ROJO_BUILD_PROJECT), "-o", "sourcemap.json" })
		run("wally-package-types", { "--sourcemap", "sourcemap.json", tostring(project.PACKAGES_PATH) })

		if fs.exists(path.join(project.PACKAGES_PATH, "Log.lua")) then
			patchLuauLog()
		end
	end

	local function installRobloxPackages()
		run("roblox-packages", {
			"install",
			"RobloxPackagesTmp",
			"--version",
			project.ROBLOX_PACKAGES_VERSION,
			"-d",
			"Foundation",
			"-d",
			"Signals",
			"-d",
			"SignalsReact",
			"-d",
			"ReactUtils",

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
			fs.removedirectory(dest, {
				recursive = true,
			})
		end
		run("mv", { "RobloxPackagesTmp/Packages", tostring(dest) })
		fs.removedirectory("RobloxPackagesTmp", {
			recursive = true,
		})

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

		local dest = path.join(project.LUAU_PACKAGES_PATH, "batteries")

		fs.createdirectory(dest, {
			makeparents = true,
		})

		for _, battery in batteries do
			run("curl", { "-LO", `https://raw.githubusercontent.com/luau-lang/lute/{commit}/batteries/{battery}` }, {
				cwd = tostring(dest),
			})
		end
	end

	local function installRbxasset()
		local fileName = "rbxasset.zip"

		run("curl", { "-LO", `https://github.com/Roblox/rbxasset/releases/download/v0.2.0/{fileName}` }, {
			cwd = tostring(project.LUAU_PACKAGES_PATH),
		})

		run("unzip", { "rbxasset.zip" }, {
			cwd = tostring(project.LUAU_PACKAGES_PATH),
		})

		fs.remove(path.join(project.LUAU_PACKAGES_PATH, fileName))
	end

	local function pruneDevelopmentFiles()
		-- Prune any third-party tests or stories that may have slipped through
		local prunedFiles = {
			"*.spec.lua*",
			"*.story.lua*",
			"*.storybook.lua*",
		}
		for _, packagesPath in { project.PACKAGES_PATH, project.ROBLOX_PACKAGES_PATH } do
			for _, pattern in prunedFiles do
				run("find", { tostring(packagesPath), "-type", "f", "-name", `"{pattern}"`, "-delete" })
			end
		end
	end

	run("lute", { "setup" })

	installRobloxPackages()
	installWallyPackages()
	installRbxasset()
	installLuteBatteries()
	pruneDevelopmentFiles()
end
