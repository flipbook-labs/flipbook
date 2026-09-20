local process = require("@std/process")

local renderStorybookPreviewComment = require("@scripts/lib/renderStorybookPreviewComment")
local resolvePlaceId = require("@scripts/lib/resolvePlaceId")
local upsertPullRequestComment = require("@scripts/lib/upsertPullRequestComment")

local COMMENT_MARKER = "<!-- flipbook-pr-preview -->"

local apiKey = assert(process.env.ROBLOX_API_KEY, "ROBLOX_API_KEY is required")
local universeId =
	assert(tonumber(process.env.ROBLOX_STORYBOOK_UNIVERSE_ID), "ROBLOX_STORYBOOK_UNIVERSE_ID must be a number")
local releaseRuntimePlaceName = assert(process.env.RELEASE_RUNTIME_PLACE_NAME, "RELEASE_RUNTIME_PLACE_NAME is required")
local branchRuntimePlaceName = assert(process.env.BRANCH_RUNTIME_PLACE_NAME, "BRANCH_RUNTIME_PLACE_NAME is required")
local githubRepository = assert(process.env.GITHUB_REPOSITORY, "GITHUB_REPOSITORY is required")
local pullRequestNumber =
	assert(tonumber(process.env.GITHUB_PULL_REQUEST_NUMBER), "GITHUB_PULL_REQUEST_NUMBER must be a number")
local githubToken = assert(process.env.GITHUB_TOKEN, "GITHUB_TOKEN is required")

local releaseRuntimePlaceId = resolvePlaceId(universeId, releaseRuntimePlaceName, apiKey)
local branchRuntimePlaceId = resolvePlaceId(universeId, branchRuntimePlaceName, apiKey)
local body = renderStorybookPreviewComment(releaseRuntimePlaceId, branchRuntimePlaceId)

upsertPullRequestComment(githubRepository, pullRequestNumber, githubToken, COMMENT_MARKER, body)
