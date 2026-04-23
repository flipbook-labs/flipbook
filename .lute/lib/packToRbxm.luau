local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.10.0")

local fs = require("@std/fs")
local path = require("@std/path")
local system = require("@std/system")

local createRojoProjectAsync = require("@scripts/lib/createRojoProjectAsync")

local run = FlipbookBatteries.run

local function packToRbxm(filePath: path.Pathlike): path.Path
	local projectPath = path.join(system.tmpdir(), "default.project.json")
	local resolvedFilePath = path.resolve(filePath)

	createRojoProjectAsync(projectPath, {
		name = path.basename(filePath),
		tree = {
			["$path"] = tostring(resolvedFilePath),
		},
	})
	local outputPath = path.resolve(`{resolvedFilePath}.rbxm`)

	run("rojo", {
		"build",
		tostring(projectPath),
		"-o",
		tostring(outputPath),
	})

	fs.remove(projectPath)

	return outputPath
end

return packToRbxm
