local fs = require("@lune/fs")
local process = require("@lune/process")
local project = require("@repo/project")

local run = require("./lib/run")

local function findLuaFiles()
	local matches = {}

	local function search(path: string)
		for _, file in fs.readDir(path) do
			local filePath = `{path}/{file}`

			if fs.isDir(filePath) then
				search(filePath)
			else
				if filePath:match(".lua$") then
					table.insert(matches, filePath)
				end
			end
		end
	end

	for _, folder in project.FOLDERS_TO_LINT do
		search(folder)
	end

	return matches
end

run("selene", project.FOLDERS_TO_LINT)

run("stylua", {
	"--check",
	table.unpack(project.FOLDERS_TO_LINT),
})

local files = findLuaFiles()
if #files > 0 then
	print("[err] the following file(s) are using the '.lua' extension. Please change to '.luau' and try again")
	print(`{table.concat(files, "\n")}`)
	process.exit(1)
end
