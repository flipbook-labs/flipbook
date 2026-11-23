local process = require("@std/process")

--[[
	The Latest release is the one GitHub badges on the repository page. GitHub
	answers 404 when there isn't one, such as when every release is a draft or
	prerelease, and this returns nil then. Reads through `gh`, given the
	repository as owner/name.
]]
local function readLatestReleaseTag(repo: string): string?
	local result = process.run({
		"gh",
		"api",
		`repos/{repo}/releases/latest`,
		"--jq",
		".tag_name",
	})
	if result.ok then
		local tag = result.stdout:gsub("%s+$", "")
		return tag
	end
	if result.stderr:find("HTTP 404", 1, true) then
		return nil
	end
	error(`Could not read the Latest release: {result.stderr}`)
end

return readLatestReleaseTag
