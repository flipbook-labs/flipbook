local constants = require("./constants")
local fs = require("@lune/fs")
local run = require("./run")
local serde = require("@lune/serde")

local pesdeToml = serde.decode("toml", fs.readFile("pesde.toml"))

type Target = "prod" | "dev"

local PRUNED_FILES = {
	"*.spec.luau",
	"*.story.luau",
	"*.storybook.luau",
}

local function compile(target: Target)
	fs.writeDir(constants.BUILD_PATH)

	local commitHash = run("git", { "rev-parse", "--short", "HEAD" })

	local env = {
		BUILD_VERSION = pesdeToml.version,
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
		constants.BUILD_PATH,
	}, {
		env = env,
	})

	if target == "dev" then
		run("darklua", {
			"process",
			"example",
			`{constants.BUILD_PATH}/Example`,
		}, {
			env = env,
		})
	end

	if target == "prod" then
		for _, pattern in PRUNED_FILES do
			run("find", { constants.BUILD_PATH, "-type", "f", "-name", pattern, "-delete" })
		end
	end
end

return compile
