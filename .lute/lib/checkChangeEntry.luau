local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local trim = require("@scripts/lib/trim")

local UNRELEASED_CHANGES_DIR = ".changes"
local MAIN_BRANCH_REF = "refs/remotes/origin/HEAD"
local REMOTE_BRANCH_PREFIX = "origin/"

local function getCurrentBranch(): string
	local result = process.run({ "git", "branch", "--show-current" })
	assert(result.ok, result.stderr)
	return trim(result.stdout)
end

local function getMainBranch(): string
	if process.env.REPOSITORY_DEFAULT_BRANCH and process.env.REPOSITORY_DEFAULT_BRANCH ~= "" then
		return process.env.REPOSITORY_DEFAULT_BRANCH
	end

	local result = process.run({ "git", "symbolic-ref", "--short", MAIN_BRANCH_REF })
	assert(result.ok, result.stderr)

	local remoteBranch = trim(result.stdout)
	assert(remoteBranch:sub(1, #REMOTE_BRANCH_PREFIX) == REMOTE_BRANCH_PREFIX, `Unexpected branch ref: {remoteBranch}`)
	return remoteBranch:sub(#REMOTE_BRANCH_PREFIX + 1)
end

local function stripQuotes(value: string): string
	local quote = value:sub(1, 1)
	if (quote == '"' or quote == "'") and value:sub(-1) == quote then
		return value:sub(2, -2)
	end
	return value
end

local function validateChangeEntry(filePath: string)
	local normalized = fs.readFileToString(filePath):gsub("\r\n", "\n")
	local lines = normalized:split("\n")
	local index = 1
	while index <= #lines and trim(lines[index]) == "" do
		index += 1
	end
	assert(trim(lines[index] or "") == "---", `{filePath}: missing opening --- frontmatter`)
	index += 1

	local bump: string? = nil
	local closed = false
	while index <= #lines do
		local line = lines[index]
		index += 1
		if trim(line) == "---" then
			closed = true
			break
		end

		-- Change entry frontmatter uses a small `key: value` subset, so the
		-- fields can be extracted without bringing in a YAML parser.
		local key, value = line:match("^%s*([%w_]+)%s*:%s*(.-)%s*$")
		if key == "bump" and value ~= nil then
			bump = stripQuotes(value)
		end
	end
	assert(closed, `{filePath}: frontmatter is not closed with ---`)
	assert(bump == "major" or bump == "minor" or bump == "patch", `{filePath}: bump must be major, minor, or patch`)

	local bodyLines: { string } = {}
	for bodyIndex = index, #lines do
		table.insert(bodyLines, lines[bodyIndex])
	end
	assert(trim(table.concat(bodyLines, "\n")) ~= "", `{filePath}: change entry has no body`)
end

local function validateChangeEntries()
	for _, entry in fs.listDirectory(UNRELEASED_CHANGES_DIR) do
		if
			entry.type == "file"
			and string.lower(path.extname(entry.name)) == ".md"
			and string.lower(entry.name) ~= "readme.md"
		then
			validateChangeEntry(tostring(path.join(UNRELEASED_CHANGES_DIR, entry.name)))
		end
	end
end

local function hasPendingChangeEntry(): boolean
	local result =
		process.run({ "git", "status", "--porcelain", "--untracked-files=all", "--", UNRELEASED_CHANGES_DIR })
	assert(result.ok, result.stderr)

	for line in result.stdout:gmatch("[^\r\n]+") do
		-- Porcelain status uses two status columns, one space, then the path,
		-- such as "A  .changes/add-entry.md" or "?? .changes/add-entry.md".
		local status = line:sub(1, 2)
		local filePath = line:sub(4)
		local fileName = string.lower(tostring(path.basename(filePath)))
		if
			(status == "??" or status:sub(1, 1) == "A")
			and string.lower(path.extname(filePath)) == ".md"
			and fileName ~= "readme.md"
		then
			return true
		end
	end

	return false
end

local function checkChangeEntry()
	validateChangeEntries()

	local isPullRequest = process.env.GITHUB_EVENT_NAME == "pull_request"
	local isMainBranch = not isPullRequest and getCurrentBranch() == getMainBranch()
	if isMainBranch then
		print("Skipping change-entry check on the repository's main branch.")
		return
	end

	if hasPendingChangeEntry() then
		print("Found a new unreleased change entry in the working tree.")
		return
	end

	local command: { string } = { "changewrite", "check" }
	if isPullRequest and process.env.GITHUB_BASE_REF and process.env.GITHUB_BASE_REF ~= "" then
		table.insert(command, "--base")
		table.insert(command, `origin/{process.env.GITHUB_BASE_REF}`)
	end
	local result = process.run(command, {
		stdio = "inherit",
	})
	if not result.ok then
		process.exit(result.exitcode)
	end
end

return checkChangeEntry
