-- Checks the docs the same way CI does. In the Docusaurus site at `docs/site`,
-- it installs the npm packages, checks every file in the repo that Prettier
-- formats, and builds the site. The build fails on a broken link or an
-- Obsidian wikilink.
--
-- Most scripts here run commands through FlipbookBatteries, a Lute package that
-- `lute run install` vendors. This one uses `@std/process` instead, so CI can
-- skip that install, which also sets up Roblox packages and tools the docs
-- don't need.

local path = require("@std/path")
local process = require("@std/process")

local project = require("@repo/project")

local SITE_PATH = path.join(project.REPO_PATH, "docs", "site")

local function npm(args: { string })
	print(`> npm {table.concat(args, " ")}`)
	local result = process.run({ "npm", table.unpack(args) }, {
		cwd = path.format(SITE_PATH),
		stdio = "inherit",
	})
	if not result.ok then
		process.exit(1)
	end
end

npm({ "ci" })
npm({ "run", "format:check" })
npm({ "run", "build" })
