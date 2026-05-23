local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local path = require("@std/path")
local system = require("@std/system")

local createRojoProjectAsync = require("@scripts/lib/createRojoProjectAsync")
local json = require("@std/json")

local run = FlipbookBatteries.run

type RojoBuildOptions = {
	project: {
		name: string,
		tree: { [string]: any },
	},
	output: path.Pathlike,
}
local function rojoBuild(options: RojoBuildOptions)
	local tempProjectPath = path.join(system.tmpdir(), "temp.project.json")

	createRojoProjectAsync(tempProjectPath, options.project :: json.Value)
	run("rojo", { "build", tempProjectPath, "--output", options.output })
end

return rojoBuild
