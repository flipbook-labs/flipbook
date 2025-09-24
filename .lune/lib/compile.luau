local constants = require("./constants")
local fs = require("@lune/fs")
local run = require("./run")
local serde = require("@lune/serde")

local wallyToml = serde.decode("toml", fs.readFile("wally.toml"))

type Target = "prod" | "dev"

local PRUNED_FILES = {
	"*.spec.luau",
	"*.story.luau",
	"*.storybook.luau",
}

local function compile(target: Target)
	local dest = `{constants.BUILD_PATH}/plugin`

	if fs.isDir(dest) then
		fs.removeDir(dest)
	end
	fs.writeDir(dest)

	local commitHash = run("git", { "rev-parse", "--short", "HEAD" })

	local env = {
		BUILD_VERSION = wallyToml.package.version,
		BUILD_CHANNEL = if target == "prod" then "production" else "development",
		BUILD_HASH = commitHash,
	}

	run("rojo", {
		"sourcemap",
		constants.ROJO_BUILD_PROJECT,
		"-o",
		constants.DARKLUA_SOURCEMAP_PATH,
	})

	print("substituting globals", env)

	run("darklua", {
		"process",
		constants.SOURCE_PATH,
		dest,
	}, {
		env = env,
	})

	if target == "dev" then
		run("darklua", {
			"process",
			"example",
			`{dest}/Example`,
		}, {
			env = env,
		})
	end

	if target == "prod" then
		for _, pattern in PRUNED_FILES do
			run("find", { dest, "-type", "f", "-name", pattern, "-delete" })
		end
	end

	run("cp", { "-R", "Packages", dest })
	run("cp", { "-R", "RobloxPackages", dest })
end

return compile
