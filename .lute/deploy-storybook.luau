local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local project = require("@repo/project")
local rojoBuild = require("@scripts/lib/rojoBuild")

local run = FlipbookBatteries.run

local DEFAULT_PLACE_NAME = "Flipbook Stories"

dotenv.config()

local args = cli.parser()

args:add("place-name", "option", {
	help = "The name of the place to create or update when deploying",
	default = DEFAULT_PLACE_NAME,
})
args:add("with-build", "flag", {
	help = "Whether to build the workspace before deploying.",
})

args:parse({ ... })

local apiKey = assert(process.env.ROBLOX_STORYBOOK_PREVIEW_API_KEY, "ROBLOX_STORYBOOK_PREVIEW_API_KEY must be set")

local placeName = args:get("place-name")
local withBuild = args:has("with-build")

-- Build processed workspace (darklua-transformed scripts with correct require paths)
run("lute", { "run", "build", "workspace", "--channel", "dev", "--clean" })

if withBuild then
	-- Build prod Flipbook.rbxm so we deploy the local build rather than the
	-- latest release — this lets us catch embedding issues before cutting a release.
	-- With --skip-reload the plugin is written to build/<channel>/Flipbook.rbxm and
	-- not copied into the local Studio plugins folder.
	run("lute", { "run", "build", "plugin", "--channel", "prod", "--skip-reload", "--clean" })
end

local basePlacePath = rojoBuild({
	output = path.join(system.tmpdir(), "flipbook-storybook.rbxl"),
	project = {
		name = DEFAULT_PLACE_NAME,
		emitLegacyScripts = false,
		tree = {
			["$className"] = "DataModel",
			ReplicatedStorage = {
				-- Note that we don't include Flipbook here because it gets
				-- injected separately by flipbook-cli with `--flipbook-model`.
				-- We're an edge case since we want to include our custom build
				-- of Flipbook, normally flipbook-cli fetches the latest release
				-- and injects that, so we're shortcircuiting that process.

				FlipbookWorkspace = {
					["$className"] = "Folder",
					Packages = {
						["$path"] = tostring(project.PACKAGES_PATH),
					},
					RobloxPackages = {
						["$path"] = tostring(project.ROBLOX_PACKAGES_PATH),
					},
					workspace = {
						["$path"] = tostring(path.join(project.BUILD_PATH, "dev/roblox/workspace")),
					},
				},
			},
		},
	},
})

local flipbookCliArgs: { string | number | boolean | path.Pathlike } = {
	"deploy",
	"--place-name",
	`"{placeName}"`,
	"--universe-id",
	project.ROBLOX_STORYBOOK_UNIVERSE_ID,
	"--place-file",
	basePlacePath,
}

if placeName == DEFAULT_PLACE_NAME then
	table.insert(flipbookCliArgs, "--place-id")
	table.insert(flipbookCliArgs, project.ROBLOX_STORYBOOK_PLACE_ID)
end

if withBuild then
	table.insert(flipbookCliArgs, "--flipbook-rbxm")
	table.insert(flipbookCliArgs, path.join(project.BUILD_PATH, "prod", project.PLUGIN_FILENAME))
end

run("/Users/marin/Code/flipbook-cli/build/flipbook-cli", flipbookCliArgs, {
	env = {
		ROBLOX_API_KEY = apiKey,
	},
})

-- run("flipbook-cli", flipbookCliArgs, {
-- 	env = {
-- 		ROBLOX_API_KEY = apiKey,
-- 	},
-- })
