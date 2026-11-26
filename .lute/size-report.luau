local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local system = require("@std/system")

local downloadMainSizeReport = require("@scripts/lib/downloadMainSizeReport")
local logger = require("@scripts/lib/logger")
local project = require("@repo/project")
local renderSizeReport = require("@scripts/lib/renderSizeReport")
local rojoBuild = require("@scripts/lib/rojoBuild")

local run = FlipbookBatteries.run

type Report = renderSizeReport.Report

local CHANNELS = { "prod", "beta", "dev" }
local ROTRIEVER_BUNDLE_NAME = "flipbook-core-rotriever"
local REPORT_JSON_PATH = path.join(project.BUILD_PATH, "size-report.json")
local REPORT_MARKDOWN_PATH = path.join(project.BUILD_PATH, "size-report.md")

-- How many commits a report's history holds before the oldest drop off.
local MAX_HISTORY_LENGTH = 50

local args = cli.parser()

args:add("script", "positional", {
	help = "Path to the script being run. Provided automatically by Lute",
})
args:add("base", "option", {
	help = "Path to another run's size-report.json to show changes from. A path with no file there is ignored",
})

args:add("compare-with-main", "flag", {
	help = "Download the newest report from main with the gh CLI and show changes from it. Overrides --base",
})
args:add("sha", "option", {
	help = "The commit being measured. Defaults to the one checked out",
})
args:add("run-url", "option", {
	help = "Link to the CI run doing the measuring, which the report's footer points at",
})

args:parse({ ... })

local function getSize(filePath: path.Pathlike): number
	return fs.metadata(filePath).size
end

-- Builds `tree` into a model file with the plugin build's Rojo settings, and
-- returns the file's size.
local function getModelSize(tree: { [string]: unknown }): number
	local modelPath = rojoBuild({
		output = path.join(system.tmpdir(), `size-report-{math.random(0, 0xffff)}.rbxm`),
		project = {
			name = "Part",
			emitLegacyScripts = false,
			tree = tree,
		},
	})
	local size = getSize(modelPath)
	fs.remove(modelPath)
	return size
end

--[[
	Returns the size of each part of the plugin built at `buildFolder`. Every
	folder at the top of the build is a part, except that each workspace member
	is a part of its own. The scripts that sit beside those folders come from
	`src/`, and they're measured together as the `src` part.
]]
local function getPartSizes(buildFolder: path.Path): { [string]: number }
	local workspaceName = path.basename(project.WORKSPACE_PATH) :: string
	local sizes: { [string]: number } = {}
	local scripts: { [string]: unknown } = {
		["$className"] = "Folder",
	}

	local function measureFolder(name: string, folder: path.Path)
		sizes[name] = getModelSize({
			["$path"] = tostring(folder),
		})
	end

	for _, entry in fs.listDirectory(buildFolder) do
		local entryPath = path.join(buildFolder, entry.name)

		if entry.type ~= "dir" then
			scripts[entry.name] = {
				["$path"] = tostring(entryPath),
			}
		elseif entry.name == workspaceName then
			for _, member in fs.listDirectory(entryPath) do
				if member.type == "dir" then
					measureFolder(`{workspaceName}/{member.name}`, path.join(entryPath, member.name))
				end
			end
		else
			measureFolder(entry.name, entryPath)
		end
	end

	sizes.src = getModelSize(scripts)

	return sizes
end

local function build(buildArgs: { string })
	local params: { string | number | boolean | path.Pathlike } = { "run", "build" }
	for _, buildArg in buildArgs do
		table.insert(params, buildArg)
	end
	run("lute", params)
end

local sha = args:get("sha")
if typeof(sha) ~= "string" or sha == "" then
	sha = run("git", { "rev-parse", "HEAD" }, {
		captureOutput = true,
	})
end
assert(typeof(sha) == "string" and sha ~= "", "couldn't work out which commit is being measured")

local report: Report = {
	sha = sha:sub(1, 7),
	bundles = {},
	channels = CHANNELS,
	parts = {},
	storybookDeployBytes = 0,
	history = {},
}

local partsByName: { [string]: renderSizeReport.Part } = {}
local rotrieverBundles: { renderSizeReport.Bundle } = {}

for _, channel in CHANNELS do
	build({
		"plugin",
		"--channel",
		channel,
		"--clean",
		"--skip-reload",
	})

	local pluginBytes = getSize(path.join(project.BUILD_PATH, channel, project.PLUGIN_FILENAME))
	table.insert(report.bundles, {
		name = `Plugin ({channel})`,
		bytes = pluginBytes,
	})
	if channel == "prod" then
		report.storybookDeployBytes += pluginBytes
	end

	for name, bytes in getPartSizes(path.join(project.BUILD_PATH, channel, "roblox")) do
		local part = partsByName[name]
		if not part then
			part = {
				name = name,
				bytes = {},
			}
			partsByName[name] = part
			table.insert(report.parts, part)
		end
		part.bytes[channel] = bytes
	end

	-- CI uploads the Rotriever bundle as a zip of its folder, so that's the
	-- size to report.
	build({
		"workspace",
		"--channel",
		channel,
		"--target",
		"rotriever",
		"--clean",
	})

	local zipPath = path.join(system.tmpdir(), `size-report-{math.random(0, 0xffff)}.zip`)
	run("zip", { "-qr", zipPath, ROTRIEVER_BUNDLE_NAME }, {
		cwd = project.BUILD_PATH,
	})
	table.insert(rotrieverBundles, {
		name = `Rotriever bundle ({channel})`,
		bytes = getSize(zipPath),
	})
	fs.remove(zipPath)
end

table.move(rotrieverBundles, 1, #rotrieverBundles, #report.bundles + 1, report.bundles)

-- Building the storybook place deletes the dev build's folder and compiles
-- it again, so this goes after the dev plugin has been measured.
build({ "storybook" })

local storybookBytes = getSize(path.join(project.BUILD_PATH, "flipbook-storybook.rbxl"))
table.insert(report.bundles, {
	name = "Storybook place",
	bytes = storybookBytes,
})
report.storybookDeployBytes += storybookBytes

-- The biggest parts come first. A part's rank is its largest size in any
-- channel, since the development-only ones have no prod size.
local function getLargestSize(part: renderSizeReport.Part): number
	local largest = 0
	for _, bytes in part.bytes do
		largest = math.max(largest, bytes)
	end
	return largest
end

table.sort(report.parts, function(a: renderSizeReport.Part, b: renderSizeReport.Part)
	local aSize, bSize = getLargestSize(a), getLargestSize(b)
	if aSize == bSize then
		return a.name < b.name
	end
	return aSize > bSize
end)

local baseReport: Report? = nil
local basePath: unknown = args:get("base")
if args:has("compare-with-main") then
	basePath = downloadMainSizeReport(path.join(system.tmpdir(), "size-report-from-main"))
end
if basePath and fs.exists(basePath :: path.Pathlike) then
	baseReport = (json.deserialize(fs.readFileToString(basePath :: path.Pathlike)) :: unknown) :: Report
end

--[[
	The history carries over from the base report, which ends with the base
	commit itself, and this run goes on the end. Measuring a commit again
	replaces its earlier entry.
]]
if baseReport and baseReport.history then
	for _, entry in baseReport.history do
		if entry.sha ~= report.sha then
			table.insert(report.history, entry)
		end
	end
end

local sizes: { [string]: number } = {}
for _, bundle in report.bundles do
	sizes[bundle.name] = bundle.bytes
end
table.insert(report.history, {
	sha = report.sha,
	bytes = sizes,
})

while #report.history > MAX_HISTORY_LENGTH do
	table.remove(report.history, 1)
end

local runUrl = args:get("run-url")
local markdown = renderSizeReport(report, baseReport, {
	runUrl = if typeof(runUrl) == "string" and runUrl ~= "" then runUrl else nil,
})

fs.writeStringToFile(REPORT_JSON_PATH, json.serialize((report :: unknown) :: json.Value, true))
fs.writeStringToFile(REPORT_MARKDOWN_PATH, markdown)

logger.info(markdown)
logger.info(`wrote {REPORT_JSON_PATH} and {REPORT_MARKDOWN_PATH}`)
