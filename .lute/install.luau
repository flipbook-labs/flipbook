local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local getDescendants = require("@scripts/lib/getDescendants")

local project = require("@repo/project")

local PACKAGES_INDEX_PATH = path.join(project.PACKAGES_PATH, "_Index")

local function move(src: path.Pathlike, dest: path.Pathlike)
	local res = process.run({ "mv", tostring(src), tostring(dest) }, {
		stdio = "inherit",
	})
	assert(res.ok, res.stderr)
end

-- Installs the dependencies in `pkg.luau`. `--vendor` copies each one into a
-- `.lpm/<key>@<rev>` folder, and the `lpm` alias in `.config.luau` points at
-- `.lpm`. When a vendored package requires through `@lpm`, the require uses
-- the `lpm` alias of whichever project vendored it. So any project that
-- vendors such a package has to define the same alias.
-- The following issue tracks removing that requirement:
-- https://github.com/flipbook-labs/flipbook/issues/694
--
-- The rest of this script requires flipbook-batteries from `.lpm`, so this
-- runs first.
do
	local res = process.run({ "lute", "pkg", "install", "--vendor" }, {
		stdio = "inherit",
	})
	assert(res.ok, "lute pkg install failed")
end

do
	local CodeQuality = require("@lpm/code-quality@v0.8.0")
	local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")

	local run = FlipbookBatteries.run
	local find = FlipbookBatteries.find
	local findAndReplace = FlipbookBatteries.findAndReplace

	-- Some of our Wally packages are written with string requires, which
	-- ModuleLoader and Jest can't load yet (flipbook-labs/module-loader#70).
	-- CodeQuality's `convertRequire` code mod rewrites them in place into
	-- instance requires. It looks each module up in the sourcemap that
	-- `installWallyPackages` writes, which covers `Packages/_Index`.
	local function patchStringRequires()
		local packages = {
			"^luaulog$",
			"^charm$",
			"^react%-charm$",
		}

		local sourceFolders: { string } = {}
		for _, package in packages do
			local packageRoot = find(tostring(PACKAGES_INDEX_PATH), package)[1]
			assert(packageRoot, `no package found matching "{package}"`)
			print(`patching {packageRoot}`)
			table.insert(sourceFolders, path.format(path.join(packageRoot, "src")))
		end

		CodeQuality.transform(CodeQuality.Mod.ConvertRequire, sourceFolders, {
			sourcemap = "sourcemap.json",
		})
	end

	local function installWallyPackages()
		run("wally", { "install" })
		run("rojo", { "sourcemap", project.SOURCEMAP_PROJECT_PATH, "-o", "sourcemap.json" })
		run("wally-package-types", { "--sourcemap", "sourcemap.json", project.PACKAGES_PATH })

		patchStringRequires()
	end

	local function installRobloxPackages()
		local tmpdir = system.tmpdir()

		run("roblox-packages", {
			"install",
			tmpdir,
			"--version",
			project.ROBLOX_PACKAGES_VERSION,
			"-d",
			"Foundation",

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
			fs.removeDirectory(dest, {
				recursive = true,
			})
		end
		move(path.join(tmpdir, "Packages"), project.ROBLOX_PACKAGES_PATH)

		-- Patch React and RoactCompat dependencies to use ours
		for _, name in { "React", "RoactCompat", "Roact" } do
			local linkers = find(project.ROBLOX_PACKAGES_PATH, `^{name}%..*`)

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

	-- Foundation's StyleSheetRegistry and Translator modules create instances
	-- as soon as they're required. They parent them to whatever Foundation's
	-- getMainGui helper returns: CoreGui when the code can read it, or the
	-- player's PlayerGui in a running game. Tests run headless in the cloud
	-- through rocale, where neither is available, so getMainGui returns nil.
	-- Each module then asserts the result isn't nil, which fails because the
	-- test runner sets `_G.__DEV__`. Translator would error on the nil parent
	-- even without the assert.
	--
	-- This patch removes the assert from both modules and falls back to
	-- Foundation's own folder in `_Index` as the parent. When getMainGui finds
	-- a GUI, the fallback goes unused. Foundation versions without these
	-- asserts have nothing to match, and the patch leaves them as they are.
	local function patchFoundationMainGui()
		local foundationRoot = path.join(project.ROBLOX_PACKAGES_PATH, "_Index", "Foundation")
		assert(fs.exists(foundationRoot), "no Foundation package found in RobloxPackages")

		for _, descendant in getDescendants(foundationRoot) do
			local extension = path.extname(descendant)
			if fs.type(descendant) ~= "file" or (extension ~= ".lua" and extension ~= ".luau") then
				continue
			end

			local source = fs.readFileToString(descendant)
			local patched, count = source:gsub(
				'local mainGui = getMainGui%(%)\ndevAssert%(mainGui ~= nil, "MainGui not found"%)\n',
				"local mainGui = getMainGui() or FoundationRoot\n"
			)
			if count > 0 then
				print(`patching {descendant}`)
				fs.writeStringToFile(descendant, patched)
			end
		end
	end

	local function installRbxasset()
		local fileName = "rbxasset.zip"
		local installPath = path.join(project.LUAU_PACKAGES_PATH, "rbxasset")

		-- rbxasset (a Lune dependency, aliased as @lunepkg) is the only thing that
		-- still lives under LuauPackages, so make sure the directory exists.
		if not fs.exists(project.LUAU_PACKAGES_PATH) then
			fs.createDirectory(project.LUAU_PACKAGES_PATH, {
				makeParents = true,
			})
		end

		if fs.exists(installPath) then
			fs.removeDirectory(installPath, {
				recursive = true,
			})
		end

		run("curl", { "-LO", `https://github.com/Roblox/rbxasset/releases/download/v0.2.0/{fileName}` }, {
			cwd = project.LUAU_PACKAGES_PATH,
		})

		run("unzip", { "rbxasset.zip" }, {
			cwd = project.LUAU_PACKAGES_PATH,
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
				run("find", { packagesPath, "-type", "f", "-name", `"{pattern}"`, "-delete" })
			end
		end
	end

	run("lute", { "setup" })

	installRobloxPackages()
	patchFoundationMainGui()
	installWallyPackages()
	installRbxasset()
	pruneDevelopmentFiles()
end
