--[[
	Posts the size report that `lute run size-report` wrote as a comment on a
	pull request, using the `gh` CLI. The report's first line is a marker that
	only size reports start with. When CI has already left a comment starting
	with it on the pull request, that comment is updated and no new one is
	added.
]]
local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local process = require("@std/process")

local project = require("@repo/project")

local run = FlipbookBatteries.run

type Comment = { id: number, body: string, user: { login: string } }

-- The account CI comments as. A copy of the report that someone else pasted
-- into a comment isn't CI's to edit, so only this account's comments count.
local CI_LOGIN = "github-actions[bot]"

local REPORT_MARKDOWN_PATH = path.join(project.BUILD_PATH, "size-report.md")

local args = cli.parser()

args:add("script", "positional", {
	help = "Path to the script being run. Provided automatically by Lute",
})
args:add("pr", "option", {
	help = "Number of the pull request to comment on",
	required = true,
})
args:add("repository", "option", {
	help = "The pull request's repository, as owner/name. Defaults to GITHUB_REPOSITORY",
})

args:parse({ ... })

local pullRequest = tonumber(args:get("pr"))
assert(pullRequest, "--pr must be a pull request number")

local repository = args:get("repository") or process.env.GITHUB_REPOSITORY
assert(typeof(repository) == "string" and repository ~= "", "pass --repository or set GITHUB_REPOSITORY")

assert(fs.exists(REPORT_MARKDOWN_PATH), `{REPORT_MARKDOWN_PATH} is missing. Run \`lute run size-report\` first`)

local marker = fs.readFileToString(REPORT_MARKDOWN_PATH):match("^[^\n]+")
assert(marker, "the size report is empty")

-- `--slurp` wraps the pages of comments in one array, so this is a list of
-- pages and each page is a list of comments.
local output = run("gh", {
	"api",
	`repos/{repository}/issues/{pullRequest}/comments`,
	"--paginate",
	"--slurp",
}, {
	captureOutput = true,
})
assert(output, "gh returned no comments")

local pages = (json.deserialize(output) :: unknown) :: { { Comment } }

local commentId: string? = nil
for _, comments in pages do
	for _, comment in comments do
		if comment.user.login == CI_LOGIN and comment.body:sub(1, #marker) == marker then
			commentId = ("%.0f"):format(comment.id)
			break
		end
	end
end

-- The `@` has `gh` read the comment's body from the file.
local body = `body=@{REPORT_MARKDOWN_PATH}`

if commentId then
	run("gh", {
		"api",
		"--method",
		"PATCH",
		`repos/{repository}/issues/comments/{commentId}`,
		"-F",
		body,
	})
	print(`updated the size report comment on #{pullRequest}`)
else
	run("gh", {
		"api",
		"--method",
		"POST",
		`repos/{repository}/issues/{pullRequest}/comments`,
		"-F",
		body,
	})
	print(`commented the size report on #{pullRequest}`)
end
