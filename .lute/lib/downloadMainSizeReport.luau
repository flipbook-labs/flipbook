local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local logger = require("@scripts/lib/logger")

local run = FlipbookBatteries.run

local WORKFLOW_FILE = "ci.yml"
local ARTIFACT_NAME = "size-report"
local REPORT_FILENAME = "size-report.json"

-- A run on `main` has no report when it's still going or failed before
-- measuring, so the search steps back through this many runs to find one.
local RUNS_TO_TRY = 10

--[[
	Every CI run uploads its size report as an artifact. This downloads the
	newest one from a push to `main` into `destFolder`, using the `gh` CLI, and
	returns the path to the report. Only pushes count, because a pull request
	from a fork whose branch is named `main` also shows up as a run on `main`. It returns nil when `gh` fails or none of
	the latest runs has a report, since a size report can still be made
	without one to compare with.
]]
local function downloadMainSizeReport(destFolder: path.Pathlike): path.Path?
	local listed, output = pcall(function()
		return run("gh", {
			"run",
			"list",
			"--workflow",
			WORKFLOW_FILE,
			"--branch",
			"main",
			"--event",
			"push",
			"--limit",
			RUNS_TO_TRY,
			"--json",
			"databaseId",
		}, {
			captureOutput = true,
		})
	end)

	if not listed or typeof(output) ~= "string" then
		logger.warn(`couldn't list the runs on main: {output}`)
		return nil
	end

	local runs = (json.deserialize(output) :: unknown) :: { { databaseId: number } }

	for _, workflowRun in runs do
		-- `gh` won't download over files from an earlier attempt.
		if fs.exists(destFolder) then
			fs.removeDirectory(destFolder, {
				recursive = true,
			})
		end

		local runId = ("%.0f"):format(workflowRun.databaseId)
		local downloaded = pcall(function()
			run("gh", {
				"run",
				"download",
				runId,
				"--name",
				ARTIFACT_NAME,
				"--dir",
				destFolder,
			})
		end)

		local reportPath = path.join(destFolder, REPORT_FILENAME)
		if downloaded and fs.exists(reportPath) then
			return reportPath
		end
	end

	logger.warn(`none of the last {#runs} runs on main has a size report`)
	return nil
end

return downloadMainSizeReport
