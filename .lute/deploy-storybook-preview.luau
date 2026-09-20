local process = require("@std/process")

local universeId = assert(process.env.ROBLOX_STORYBOOK_UNIVERSE_ID, "ROBLOX_STORYBOOK_UNIVERSE_ID is required")
local placeName = assert(process.env.BRANCH_RUNTIME_PLACE_NAME, "BRANCH_RUNTIME_PLACE_NAME is required")

local result = process.run({
	"flipbook-cli",
	"deploy",
	"--universe-id",
	universeId,
	"--place-name",
	placeName,
	"--place-file",
	"build/flipbook-storybook.rbxl",
	"--flipbook-rbxm",
	"build/prod/Flipbook.rbxm",
}, {
	stdio = "inherit",
})

if not result.ok then
	process.exit(result.exitcode)
end
