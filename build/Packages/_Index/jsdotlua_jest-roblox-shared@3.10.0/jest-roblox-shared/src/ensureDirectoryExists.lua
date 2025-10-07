-- moved from jest-snapshot/utils.lua

local LuauPolyfill = require(script.Parent.Parent:WaitForChild('luau-polyfill'))
local Error = LuauPolyfill.Error

local getParent = require(script.Parent:WaitForChild('getParent'))
local getDataModelService = require(script.Parent:WaitForChild('getDataModelService'))

local FileSystemService = getDataModelService("FileSystemService")

local function ensureDirectoryExists(filePath: string)
	-- ROBLOX deviation: gets path of parent directory, GetScriptFilePath can only be called on ModuleScripts
	local path = getParent(filePath, 1)
	local ok, err = pcall(function()
		if FileSystemService and not FileSystemService:Exists(path) then
			FileSystemService:CreateDirectories(path)
		end
	end)

	if not ok and err:find("Error%(13%): Access Denied%. Path is outside of sandbox%.") then
		error(
			Error.new(
[[Provided path is invalid: you likely need to provide a different argument to --fs.readwrite.
You may need to pass in `--fs.readwrite=$PWD`]]			
)
		)
	end
end

return ensureDirectoryExists
