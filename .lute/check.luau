local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.12.0")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local run = FlipbookBatteries.run

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

checkChangeEntry()
run("lute", { "setup" })
run("lute", { "run", "lint" })
run("lute", { "run", "analyze" })
run("lute", {
	"run",
	"build",
	"plugin",
	"--channel",
	"dev",
	"--clean",
	"--skip-reload",
	"--output",
	tostring(path.join(system.tmpdir(), "flipbook-check.rbxm")),
})
