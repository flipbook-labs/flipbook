local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local function trim(value: string): string
	local withoutLeadingWhitespace = value:gsub("^%s+", "")
	local trimmed = withoutLeadingWhitespace:gsub("%s+$", "")
	return trimmed
end

local function getCurrentBranch(): string
	local result = process.run({ "git", "branch", "--show-current" })
	assert(result.ok, result.stderr)
	return trim(result.stdout)
end

local function splitLines(value: string): { string }
	local lines = {}
	local normalized = value:gsub("\r\n", "\n")
	for line in (`{normalized}\n`):gmatch("(.-)\n") do
		table.insert(lines, line)
	end
	return lines
end

local function stripQuotes(value: string): string
	local quote = value:sub(1, 1)
	if (quote == '"' or quote == "'") and value:sub(-1) == quote then
		return value:sub(2, -2)
	end
	return value
end

local function validateChangeEntry(filePath: string)
	local lines = splitLines(fs.readFileToString(filePath))
	local index = 1
	while index <= #lines and trim(lines[index]) == "" do
		index += 1
	end
	assert(trim(lines[index] or "") == "---", `{filePath}: missing opening --- frontmatter`)
	index += 1

	local bump = nil
	local closed = false
	while index <= #lines do
		local line = lines[index]
		index += 1
		if trim(line) == "---" then
			closed = true
			break
		end

		local key, value = line:match("^%s*([%w_]+)%s*:%s*(.-)%s*$")
		if key == "bump" and value ~= nil then
			bump = stripQuotes(value)
		end
	end
	assert(closed, `{filePath}: frontmatter is not closed with ---`)
	assert(bump == "major" or bump == "minor" or bump == "patch", `{filePath}: bump must be major, minor, or patch`)

	local bodyLines = {}
	for bodyIndex = index, #lines do
		table.insert(bodyLines, lines[bodyIndex])
	end
	assert(trim(table.concat(bodyLines, "\n")) ~= "", `{filePath}: change entry has no body`)
end

local function validateChangeEntries()
	for _, entry in fs.listDirectory(".changes") do
		if
			entry.type == "file"
			and string.lower(path.extname(entry.name)) == ".md"
			and string.lower(entry.name) ~= "readme.md"
		then
			validateChangeEntry(tostring(path.join(".changes", entry.name)))
		end
	end
end

local function hasPendingChangeEntry(): boolean
	local result = process.run({ "git", "status", "--porcelain", "--untracked-files=all", "--", ".changes" })
	assert(result.ok, result.stderr)

	for line in result.stdout:gmatch("[^\r\n]+") do
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
	local isMain = if process.env.GITHUB_REF_NAME
		then process.env.GITHUB_REF_NAME == "main"
		else getCurrentBranch() == "main"
	if not isPullRequest and isMain then
		print("Skipping change-entry check on main.")
		return
	end

	if hasPendingChangeEntry() then
		print("Found a new unreleased change entry in the working tree.")
		return
	end

	local command = { "changewrite", "check" }
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
