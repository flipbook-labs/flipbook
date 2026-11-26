local fs = require("@std/fs")
local path = require("@std/path")
local system = require("@std/system")
local test = require("@std/test")

local prunePackagesAsync = require("./prunePackagesAsync")

local INSTALL_FOLDER_NAMES = { "Packages", "RobloxPackages" }

local treeCount = 0

-- Writes each file to a new folder in the temp directory and returns the
-- folder. The keys are file paths inside it.
local function writeTree(files: { [string]: string }): path.Path
	treeCount += 1
	local root = path.join(system.tmpdir(), `prune-packages-spec-{os.time()}-{treeCount}`)

	for filePath, source in files do
		local fullPath = path.join(root, filePath)
		fs.createDirectory(path.dirname(fullPath), {
			makeParents = true,
		})
		fs.writeStringToFile(fullPath, source)
	end

	return root
end

-- The linker Wally writes at the top of `Packages`.
local function getTopLinker(packageFolder: string, name: string): string
	return `return require(script.Parent._Index["{packageFolder}"]["{name}"])\n`
end

-- The linker Wally writes beside a package for one of its dependencies.
local function getInnerLinker(packageFolder: string, name: string): string
	return `return require(script.Parent.Parent["{packageFolder}"]["{name}"])\n`
end

local function prune(root: path.Path): string
	local removedPackages = prunePackagesAsync({
		buildFolder = root,
		installFolderNames = INSTALL_FOLDER_NAMES,
	})
	return table.concat(removedPackages, ",")
end

test.suite("prunePackagesAsync", function(suite)
	suite:case("removes a package nothing requires and keeps one the plugin requires", function(assert)
		local root = writeTree({
			["Plugin.plugin.luau"] = "local Used = require(script.Parent.Packages.Used)\n",
			["Packages/Used.lua"] = getTopLinker("acme_used@1.0.0", "used"),
			["Packages/Unused.lua"] = getTopLinker("acme_unused@1.0.0", "unused"),
			["Packages/_Index/acme_used@1.0.0/used/init.lua"] = "return {}\n",
			["Packages/_Index/acme_unused@1.0.0/unused/init.lua"] = "return {}\n",
			["RobloxPackages/_Index/.keep"] = "",
		})

		assert.eq(prune(root), "acme_unused@1.0.0")
		assert.eq(fs.exists(path.join(root, "Packages/_Index/acme_used@1.0.0/used/init.lua")), true)
		assert.eq(fs.exists(path.join(root, "Packages/_Index/acme_unused@1.0.0")), false)
	end)

	suite:case("keeps a package that a required package requires", function(assert)
		local root = writeTree({
			["workspace/core/init.luau"] = "local Used = require(script.Parent.Parent.Packages.Used)\n",
			["Packages/Used.lua"] = getTopLinker("acme_used@1.0.0", "used"),
			["Packages/_Index/acme_used@1.0.0/Dep.lua"] = getInnerLinker("acme_dep@2.0.0", "dep"),
			["Packages/_Index/acme_used@1.0.0/used/init.lua"] = "local Dep = require(script.Parent.Dep)\n",
			["Packages/_Index/acme_dep@2.0.0/dep/init.lua"] = "return {}\n",
			["RobloxPackages/_Index/.keep"] = "",
		})

		assert.eq(prune(root), "")
		assert.eq(fs.exists(path.join(root, "Packages/_Index/acme_dep@2.0.0/dep/init.lua")), true)
	end)

	suite:case("removes a package that only a package's tests and scripts require", function(assert)
		local root = writeTree({
			["Plugin.plugin.luau"] = "local Used = require(script.Parent.Packages.Used)\n",
			["Packages/Used.lua"] = getTopLinker("acme_used@1.0.0", "used"),
			["Packages/_Index/acme_used@1.0.0/TestKit.lua"] = getInnerLinker("acme_test-kit@1.0.0", "test-kit"),
			["Packages/_Index/acme_used@1.0.0/Runner.lua"] = getInnerLinker("acme_runner@1.0.0", "runner"),
			["Packages/_Index/acme_used@1.0.0/used/init.lua"] = "return {}\n",
			["Packages/_Index/acme_used@1.0.0/used/thing.spec.lua"] = "local TestKit = require(script.Parent.Parent.TestKit)\n",
			["Packages/_Index/acme_used@1.0.0/used/run.server.lua"] = "local Runner = require(script.Parent.Parent.Runner)\n",
			["Packages/_Index/acme_test-kit@1.0.0/test-kit/init.lua"] = "return {}\n",
			["Packages/_Index/acme_runner@1.0.0/runner/init.lua"] = "return {}\n",
			["RobloxPackages/_Index/.keep"] = "",
		})

		assert.eq(prune(root), "acme_runner@1.0.0,acme_test-kit@1.0.0")
		assert.eq(fs.exists(path.join(root, "Packages/_Index/acme_used@1.0.0/used/init.lua")), true)
	end)

	suite:case("follows a linker that requires a linker in another install folder", function(assert)
		local rewrittenLinker = table.concat({
			'local Root = script:FindFirstAncestor("RobloxPackages")',
			"local Package = require(Root.Parent.Packages.React)",
			"return Package",
			"",
		}, "\n")
		local rotrieverLinker = table.concat({
			"local PackageIndex = script.Parent._Index",
			'local Package = require(PackageIndex["Foundation"]["Foundation"])',
			"return Package",
			"",
		}, "\n")

		local root = writeTree({
			["Plugin.plugin.luau"] = "local Foundation = require(script.Parent.RobloxPackages.Foundation)\n",
			["RobloxPackages/Foundation.lua"] = rotrieverLinker,
			["RobloxPackages/_Index/Foundation/React.lua"] = rewrittenLinker,
			["RobloxPackages/_Index/Foundation/Foundation/init.lua"] = "local React = require(script.Parent.React)\n",
			["Packages/React.lua"] = getTopLinker("jsdotlua_react@17.0.0", "react"),
			["Packages/_Index/jsdotlua_react@17.0.0/react/init.lua"] = "return {}\n",
			["Packages/_Index/acme_unused@1.0.0/unused/init.lua"] = "return {}\n",
		})

		assert.eq(prune(root), "acme_unused@1.0.0")
		assert.eq(fs.exists(path.join(root, "Packages/_Index/jsdotlua_react@17.0.0/react/init.lua")), true)
		assert.eq(fs.exists(path.join(root, "RobloxPackages/_Index/Foundation/Foundation/init.lua")), true)
	end)

	suite:case("removes the linkers that required a removed package and keeps the rest", function(assert)
		local root = writeTree({
			["Plugin.plugin.luau"] = "local Used = require(script.Parent.Packages.Used)\n",
			["Packages/Used.lua"] = getTopLinker("acme_used@1.0.0", "used"),
			["Packages/Unused.lua"] = getTopLinker("acme_unused@1.0.0", "unused"),
			["Packages/_Index/acme_used@1.0.0/Unused.lua"] = getInnerLinker("acme_unused@1.0.0", "unused"),
			["Packages/_Index/acme_used@1.0.0/used/init.lua"] = "return {}\n",
			["Packages/_Index/acme_unused@1.0.0/unused/init.lua"] = "return {}\n",
			["RobloxPackages/_Index/.keep"] = "",
		})

		prune(root)

		assert.eq(fs.exists(path.join(root, "Packages/Unused.lua")), false)
		assert.eq(fs.exists(path.join(root, "Packages/_Index/acme_used@1.0.0/Unused.lua")), false)
		assert.eq(fs.exists(path.join(root, "Packages/Used.lua")), true)
	end)

	suite:case("doesn't count a linker whose name only starts another linker's name", function(assert)
		local root = writeTree({
			["Plugin.plugin.luau"] = "local Used = require(script.Parent.Packages.Used)\n",
			["Packages/Used.lua"] = getTopLinker("acme_used@1.0.0", "used"),
			["Packages/_Index/acme_used@1.0.0/React.lua"] = getInnerLinker("jsdotlua_react@17.0.0", "react"),
			["Packages/_Index/acme_used@1.0.0/ReactRoblox.lua"] = getInnerLinker(
				"jsdotlua_react-roblox@17.0.0",
				"react-roblox"
			),
			["Packages/_Index/acme_used@1.0.0/used/init.lua"] = "local ReactRoblox = require(script.Parent.ReactRoblox)\n",
			["Packages/_Index/jsdotlua_react@17.0.0/react/init.lua"] = "return {}\n",
			["Packages/_Index/jsdotlua_react-roblox@17.0.0/react-roblox/init.lua"] = "return {}\n",
			["RobloxPackages/_Index/.keep"] = "",
		})

		assert.eq(prune(root), "jsdotlua_react@17.0.0")
		assert.eq(
			fs.exists(path.join(root, "Packages/_Index/jsdotlua_react-roblox@17.0.0/react-roblox/init.lua")),
			true
		)
	end)
end)
