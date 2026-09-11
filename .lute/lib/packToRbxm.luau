local path = require("@std/path")

local rojoBuild = require("./rojoBuild")

local function packToRbxm(filePath: path.Pathlike): path.Path
	local resolvedFilePath = path.resolve(filePath)

	local modelPath = rojoBuild({
		output = path.resolve(`{resolvedFilePath}.rbxm`),
		project = {
			name = tostring(path.basename(filePath)),
			tree = {
				["$path"] = tostring(resolvedFilePath),
			},
		},
	})

	return modelPath
end

return packToRbxm
