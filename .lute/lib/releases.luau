-- Reads the repository's GitHub releases, and whether prod is rolled back.
--
-- Each function takes the repository as owner/name and calls the GitHub API
-- through `gh`, which needs to be signed in, through GH_TOKEN in CI.
local process = require("@std/process")

export type Release = {
	tag: string,
	publishedAt: string,
}

-- A prod rollback in effect. The rolled-back-to release is marked Latest,
-- while the newest release is the one it replaced or a later one.
export type RollbackState = {
	restoredTag: string,
	newestTag: string,
}

local releases = {}

local function run(command: { string }): string
	local result = process.run(command)
	assert(result.ok, `{table.concat(command, " ")} failed: {result.stderr}`)
	return (result.stdout:gsub("%s+$", ""))
end

-- The published releases among the newest 100 releases, oldest first. Drafts
-- never reach the Creator Store, and GitHub can't mark a prerelease as Latest,
-- so both are left out.
function releases.readPublished(repo: string): { Release }
	local output = run({
		"gh",
		"api",
		`repos/{repo}/releases?per_page=100`,
		"--jq",
		"[.[] | select((.draft | not) and (.prerelease | not))] | sort_by(.published_at) | .[]"
			.. ' | "\\(.tag_name) \\(.published_at)"',
	})

	local published = {}
	for tag, publishedAt in output:gmatch("(%S+) (%S+)") do
		table.insert(published, { tag = tag :: string, publishedAt = publishedAt :: string })
	end
	return published
end

-- The Latest release is the one GitHub badges on the repository page. Returns
-- nil when the repository has none yet.
function releases.readLatestTag(repo: string): string?
	local result = process.run({ "gh", "api", `repos/{repo}/releases/latest`, "--jq", ".tag_name" })
	if result.ok then
		return (result.stdout:gsub("%s+$", ""))
	end
	if result.stderr:find("HTTP 404", 1, true) then
		return nil
	end
	error(`Could not read the Latest release: {result.stderr}`)
end

-- New releases become Latest when they're published, and a prod rollback
-- marks the release it restored as Latest. So prod counts as rolled back when
-- Latest isn't the newest release. Returns nil when it isn't.
function releases.readRollbackState(repo: string): RollbackState?
	local latestTag = releases.readLatestTag(repo)
	local published = releases.readPublished(repo)
	local newest = published[#published]

	if latestTag == nil or newest == nil or newest.tag == latestTag then
		return nil
	end
	return { restoredTag = latestTag, newestTag = newest.tag }
end

return releases
