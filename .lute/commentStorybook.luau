local process = require("@std/process")

local env = process.env
local apiKey = assert(env.ROBLOX_API_KEY, "ROBLOX_API_KEY must be set")
local githubToken = assert(env.GITHUB_TOKEN, "GITHUB_TOKEN must be set")
local universeId = assert(env.ROBLOX_STORYBOOK_UNIVERSE_ID, "ROBLOX_STORYBOOK_UNIVERSE_ID must be set")
local placeName = assert(env.ROBLOX_STORYBOOK_PLACE_NAME, "ROBLOX_STORYBOOK_PLACE_NAME must be set")
local pullRequestNumber = assert(env.GITHUB_PULL_REQUEST_NUMBER, "GITHUB_PULL_REQUEST_NUMBER must be set")
local repository = assert(env.GITHUB_REPOSITORY, "GITHUB_REPOSITORY must be set")

local result = process.run({
	"flipbook-cli",
	"comment",
	"--pr",
	pullRequestNumber,
	"--universe-id",
	universeId,
	"--place-name",
	placeName,
	"--github-repository",
	repository,
}, {
	stdio = "inherit",
	env = {
		GITHUB_TOKEN = githubToken,
		ROBLOX_API_KEY = apiKey,
	},
})

if not result.ok then
	process.exit(result.exitcode)
end
