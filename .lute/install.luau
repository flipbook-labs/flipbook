local fs = require("@std/fs")
local json = require("@std/json")
local luau = require("@std/luau")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local getDescendants = require("@scripts/lib/getDescendants")

local project = require("@repo/project")

local LOCKFILE_PATH = path.join(project.REPO_PATH, "pkg.lock.luau")
local PACKAGES_INDEX_PATH = path.join(project.PACKAGES_PATH, "_Index")

-- `lute pkg install` puts each dependency in the Loom store, `~/.loom/store`,
-- under a folder whose name includes hashes of its source and rev. Requires
-- resolve only through aliases in `.config.luau`, which can't name a dependency
-- from the lockfile. So after installing, this copies each dependency into
-- `LuauPackages/<name>`, using its name from `pkg.luau`, and `.config.luau`
-- aliases those folders. https://github.com/flipbook-labs/flipbook/issues/689
-- tracks removing this once Lute resolves dependencies by name.

type Lockfile = {
	dependencies: { [string]: string },
	devDependencies: { [string]: string }?,
	packages: { [string]: { installPath: string } },
}

local function move(src: path.Pathlike, dest: path.Pathlike)
	local res = process.run({ "mv", tostring(src), tostring(dest) }, {
		stdio = "inherit",
	})
	assert(res.ok, res.stderr)
end

-- The lockfile writes `@pkg/` for the store, and the path of a dependency
-- without a `target` ends in `/.`.
local function getStorePath(lockfile: Lockfile, key: string): path.Path
	local installPath = lockfile.packages[key].installPath
	local relative = installPath:gsub("^@pkg/", ""):gsub("/%.$", "")
	return path.join(process.homedir(), ".loom", "store", relative)
end

local function copyDirectory(src: path.Path, dest: path.Path)
	fs.createDirectory(dest, { makeParents = true })
	for _, entry in fs.listDirectory(src) do
		local from = path.join(src, entry.name)
		local to = path.join(dest, entry.name)
		if entry.type == "dir" then
			copyDirectory(from, to)
		else
			fs.copy(from, to)
		end
	end
end

-- The rest of this script requires flipbook-batteries through its alias, so the
-- Loom packages are installed and copied into `LuauPackages/` first.
do
	local res = process.run({ "lute", "pkg", "install" }, {
		stdio = "inherit",
	})
	assert(res.ok, "lute pkg install failed")

	local lockfile: Lockfile = luau.loadModule(tostring(LOCKFILE_PATH))

	-- Clearing the folder first drops dependencies that `pkg.luau` no longer
	-- lists. It also removes rbxasset, which `installRbxasset` puts back below.
	if fs.exists(project.LUAU_PACKAGES_PATH) then
		fs.removeDirectory(project.LUAU_PACKAGES_PATH, { recursive = true })
	end

	for _, dependencies in { lockfile.dependencies, lockfile.devDependencies or {} } do
		for name, key in dependencies do
			copyDirectory(getStorePath(lockfile, key), path.join(project.LUAU_PACKAGES_PATH, name))
		end
	end

	print(`vendored Loom dependencies into {project.LUAU_PACKAGES_PATH}`)
end

do
	local FlipbookBatteries = require("@flipbook-batteries")

	local run = FlipbookBatteries.run
	local find = FlipbookBatteries.find
	local findAndReplace = FlipbookBatteries.findAndReplace

	-- Some of our Wally packages are written with string requires which are not
	-- yet supported by ModuleLoader or Jest. To allow us to still use these
	-- packages, this function patches them using darklua to resolve the string
	-- requires to Roblox ones
	local function patchStringRequires()
		local packages = {
			"^luaulog$",
			"^charm$",
			"^react%-charm$",
		}

		for _, package in packages do
			local packageRoot = find(tostring(PACKAGES_INDEX_PATH), package)[1]

			assert(packageRoot, `no package found matching "{package}"`)

			print(`patching {packageRoot}`)

			local darkluaConfig = {
				process = {
					{
						rule = "convert_require",
						current = {
							name = "luau",
						},
						target = {
							name = "roblox",
							indexing_style = "property",
						},
					},
				},
			}

			local darkluaConfigPath = path.join(packageRoot, ".darklua.json")
			fs.writeStringToFile(darkluaConfigPath, json.serialize(darkluaConfig, true))

			run("darklua", { "process", "src", "src" }, {
				cwd = packageRoot,
			})

			-- Darklua doesn't seem to handle `./Foo` paths without a sourcemap,
			-- and getting the sourcemap working is proving difficult. So the
			-- following just does a quick pass to convert `"./Foo"` into
			-- `script.Parent.Foo`
			for _, descendant in getDescendants(packageRoot) do
				if path.extname(descendant) == ".luau" then
					findAndReplace(descendant, `require%("%./(%w+)"%)`, "require(script.Parent.%1)")
				end
			end
		end
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

		-- rbxasset is a Lune dependency, which Lune requires as `@lunepkg`. It
		-- sits in LuauPackages beside the Loom dependencies.
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
