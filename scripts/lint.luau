local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local process = require("@lute/process")

local project = require("@repo/project")

local run = FlipbookBatteries.run
local findWhere = FlipbookBatteries.findWhere

local function findLuaFiles()
	local result = {}

	for _, folder in project.FOLDERS_TO_LINT do
		local matches = findWhere(folder, function(path)
			local isMatch = path:match(".lua$")
			return isMatch ~= nil
		end)

		for _, match in matches do
			table.insert(result, match)
		end
	end

	return result
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
