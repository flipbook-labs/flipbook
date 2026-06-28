local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.11.1")
local fs = require("@std/fs")
local path = require("@std/path")
local system = require("@std/system")

local createRojoProjectAsync = require("@scripts/lib/createRojoProjectAsync")
local json = require("@std/json")

local run = FlipbookBatteries.run

type RojoBuildOptions = {
	project: {
		name: string,
		emitLegacyScripts: boolean?,
		tree: { [string]: any },
	},
	output: path.Pathlike,
}
local function rojoBuild(options: RojoBuildOptions): path.Path
	-- Random suffix so two builds sharing a tmpdir don't clobber each other's
	-- project file. `rojo build` doesn't care where the project file lives, so
	-- we keep it out of the repo entirely.
	local tempProjectName = `temp-{math.random(0, 0xffff)}.project.json`
	local tempProjectPath =
		createRojoProjectAsync(path.join(system.tmpdir(), tempProjectName), options.project :: json.Value)

	local ok, err = (pcall :: any)(function()
		run("rojo", { "build", tempProjectPath, "--output", options.output })
	end)
	fs.remove(tempProjectPath)

	if not ok then
		error(err)
	end

	return path.resolve(options.output)
end

return rojoBuild
