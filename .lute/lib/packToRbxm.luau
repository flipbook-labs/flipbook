local path = require("@std/path")

local rojoBuild = require("./rojoBuild")

local function packToRbxm(filePath: path.Pathlike): path.Path
	local resolvedFilePath = path.resolve(filePath)
	local outputPath = path.resolve(`{resolvedFilePath}.rbxm`)

	rojoBuild({
		output = outputPath,
		project = {
			name = tostring(path.basename(filePath)),
			tree = {
				["$path"] = tostring(resolvedFilePath),
			},
		},
	})

	return outputPath
end

return packToRbxm
