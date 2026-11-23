local readLatestReleaseTag = require("@scripts/lib/releases/readLatestReleaseTag")
local readPublishedReleases = require("@scripts/lib/releases/readPublishedReleases")
local types = require("@scripts/lib/releases/types")

-- New releases become Latest when they're published, and a prod rollback
-- marks the release it restored as Latest. So prod counts as rolled back when
-- Latest isn't the newest release. Returns nil when it isn't.
local function readRollbackState(repo: string): types.RollbackState?
	local latestTag = readLatestReleaseTag(repo)
	local published = readPublishedReleases(repo)
	local newest = published[#published]

	if latestTag == nil or newest == nil or newest.tag == latestTag then
		return nil
	end
	return { restoredTag = latestTag, newestTag = newest.tag }
end

return readRollbackState
