local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local path = require("@std/path")
local system = require("@std/system")

local createRojoProjectAsync = require("@scripts/lib/createRojoProjectAsync")

local run = FlipbookBatteries.run

type RojoBuildOptions = {
	project: {
		name: string,
		tree: { [string]: any },
	},
	output: string,
}
local function rojoBuild(options: RojoBuildOptions)
	local tempProjectPath = path.join(system.tmpdir(), "temp.project.json")

	createRojoProjectAsync(tempProjectPath, options.project)
	run("rojo", { "build", tempProjectPath, "--output", options.output })
end

return rojoBuild
