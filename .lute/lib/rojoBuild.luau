local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
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
	local tempProjectPath = path.join(system.tmpdir(), "temp.project.json")
	local output = path.resolve(options.output)

	createRojoProjectAsync(tempProjectPath, options.project :: json.Value)
	run("rojo", { "build", tempProjectPath, "--output", output })

	return output
end

return rojoBuild
