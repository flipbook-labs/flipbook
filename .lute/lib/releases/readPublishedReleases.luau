local process = require("@std/process")

local types = require("@scripts/lib/releases/types")

--[[
	Every published release of the repository (owner/name), oldest first, read
	through `gh`. Drafts never reach the Creator Store. Prereleases are left out
	too, because GitHub can't mark one as Latest, so the rollback banner
	couldn't track it.
]]
local function readPublishedReleases(repo: string): { types.Release }
	-- --paginate applies the filter to each page of the API's results, so the
	-- releases are sorted here once every page is in.
	local result = process.run({
		"gh",
		"api",
		"--paginate",
		`repos/{repo}/releases?per_page=100`,
		"--jq",
		'.[] | select((.draft | not) and (.prerelease | not)) | "\\(.tag_name) \\(.published_at)"',
	})
	assert(result.ok, `Could not read releases: {result.stderr}`)

	local published: { types.Release } = {}
	for tag, publishedAt in result.stdout:gmatch("(%S+) (%S+)") do
		table.insert(published, { tag = tag :: string, publishedAt = publishedAt :: string })
	end
	table.sort(published, function(a: types.Release, b: types.Release)
		return a.publishedAt < b.publishedAt
	end)
	return published
end

return readPublishedReleases
