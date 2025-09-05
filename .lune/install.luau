local run = require("./lib/run")

local function installWallyPackages()
	run("wally", { "install" })
	run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" })

	-- For some reason the default stdio of "inherit" results in WPT hanging
	-- indefinitely. Since we don't need the output in this case, we change to a
	-- stdio that won't hang
	run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" }, {
		stdio = "forward",
	})
end

local function installWallyPackagesForCodeSamples()
	run("wally", { "install" }, {
		cwd = "code-samples",
	})
	run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" }, {
		cwd = "code-samples",
	})
	run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" }, {
		cwd = "code-samples",
		stdio = "forward",
	})
end

local function installRobloxPackages()
	run("roblox-packages", { "install", "RobloxPackages" })
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

installWallyPackages()
installWallyPackagesForCodeSamples()
installRobloxPackages()
installRbxasset()
