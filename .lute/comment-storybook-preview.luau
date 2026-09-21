local cli = require("@batteries/cli")
local process = require("@std/process")

local renderStorybookPreviewComment = require("@scripts/lib/renderStorybookPreviewComment")
local resolvePlaceId = require("@scripts/lib/resolvePlaceId")
local upsertPullRequestComment = require("@scripts/lib/upsertPullRequestComment")

local COMMENT_MARKER = "<!-- flipbook-pr-preview -->"

local args = cli.parser()

args:add("script", "positional", {
	hidden = true,
})
args:add("universe-id", "option", {
	help = "Required. Universe containing both Storybook preview places.",
})
args:add("release-place-name", "option", {
	help = "Required. Name of the preview place that uses the released Flipbook runtime.",
})
args:add("branch-place-name", "option", {
	help = "Required. Name of the preview place that uses the branch Flipbook runtime.",
})
args:add("pull-request", "option", {
	help = "Required. Pull request number whose preview comment should be updated.",
})
args:add("repository", "option", {
	help = "GitHub repository in owner/name form. Can also use GITHUB_REPOSITORY.",
})
args:add("api-key", "option", {
	help = "Roblox API key. Can also use ROBLOX_API_KEY.",
})
args:add("github-token", "option", {
	help = "GitHub token. Can also use GITHUB_TOKEN.",
})
args:add("help", "flag", {
	help = "Show this help message.",
})

args:parse({ ... })

if args:has("help") then
	print(args:usage("lute run comment-storybook-preview"))
	print("")
	print(args:help())
	return
end

local universeIdValue = args:get("universe-id")
local universeId = assert(tonumber(universeIdValue), `--universe-id must be a number, got "{universeIdValue}"`)
local releaseRuntimePlaceName = assert(args:get("release-place-name"), "--release-place-name is required")
local branchRuntimePlaceName = assert(args:get("branch-place-name"), "--branch-place-name is required")
local pullRequestValue = args:get("pull-request")
local pullRequestNumber =
	assert(tonumber(pullRequestValue), `--pull-request must be a number, got "{pullRequestValue}"`)
local githubRepository =
	assert(args:get("repository") or process.env.GITHUB_REPOSITORY, "--repository or GITHUB_REPOSITORY is required")
local apiKey = assert(args:get("api-key") or process.env.ROBLOX_API_KEY, "--api-key or ROBLOX_API_KEY is required")
local githubToken =
	assert(args:get("github-token") or process.env.GITHUB_TOKEN, "--github-token or GITHUB_TOKEN is required")

local releaseRuntimePlaceId = resolvePlaceId(universeId, releaseRuntimePlaceName, apiKey)
local branchRuntimePlaceId = resolvePlaceId(universeId, branchRuntimePlaceName, apiKey)
local body = renderStorybookPreviewComment(releaseRuntimePlaceId, branchRuntimePlaceId)

upsertPullRequestComment(githubRepository, pullRequestNumber, githubToken, COMMENT_MARKER, body)
