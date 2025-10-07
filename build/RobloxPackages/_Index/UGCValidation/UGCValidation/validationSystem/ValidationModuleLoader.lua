--!nonstrict
--[[
    This file preloads all validation modules based on ValidationEnums.ValidationModule, and provides a getter based on the enum.
    Requiring module names dynamically like this is frowned upon, so we put it independently in this nonstrict file.
    This file also ensures the validationmodule follows ValidationEnums.ValidationConfig and creates default values.
    This allows us to get an immediate error if the module contains unexpected members, or if any files tries to use unavailable configs (like a typo).
]]

local root = script.Parent.Parent
local Types = require(root.util.Types)
local ValidationEnums = require(root.validationSystem.ValidationEnums)
local testFolders = root.validationFolders
local ValidationModuleLoader = {}

local existingEnums = {}
for tableName, enumTable in ValidationEnums do
	existingEnums[tableName] = {}
	if typeof(enumTable) == "table" then
		for k, _ in enumTable do
			existingEnums[tableName][k] = true
		end
	end
end

local function tableOnlyHasExistingEnums(testEnum: string, provided: { string }, tableName: string)
	if typeof(provided) ~= "table" then
		error(`Invalid config option {tableName} inside of {testEnum} - expected to be table`)
	end

	for _, v in provided do
		if not existingEnums[tableName][v] then
			error(`Invalid config option {v} in {tableName} inside of {testEnum}`)
		end
	end
end

local function defaultFlagCheck()
	return true
end

local preloads = {}
for _, testEnum in ValidationEnums.ValidationModule do
	-- First, ensure the module actually exists
	local folderName = string.lower(testEnum)
	local valFolder = testFolders:FindFirstChild(folderName)
	if valFolder == nil then
		error(`{testEnum} validation folder is missing from validationFolders`)
	end

	local valFile = valFolder:FindFirstChild(folderName)
	if valFolder == nil or not valFile:IsA("ModuleScript") then
		error(`{testEnum}.lua validation file is missing from validationFolders/{testEnum}`)
	end

	local valModule = require(valFile)
	-- Make sure the module doesnt have any unexpected properties
	for k, _ in valModule do
		if typeof(k) ~= "string" then
			error(`{testEnum}.lua contains non-string key ` .. tostring(k))
		elseif k:lower() ~= k then
			error(`{testEnum}.lua contains non-lowercase key ` .. tostring(k))
		elseif not existingEnums.ValidationConfig[k:upper()] then
			error(
				`{testEnum}.lua contains unexpected member {k}. Check for typos or add an extra ValidationEnums.ValidationConfig`
			)
		end
	end

	-- Fill in default values for unspecified configs. CANNOT BE NIL (as we later enforce that indexing nil is an error)
	valModule.fflag = valModule.fflag or defaultFlagCheck
	valModule.categories = valModule.categories or {}
	valModule.is_quality = valModule.is_quality or false
	valModule.required_data = valModule.required_data or {}
	valModule.prereq_tests = valModule.prereq_tests or {}
	if valModule.run == nil or typeof(valModule.run) ~= "function" then
		error(`Missing module run function in {testEnum}`)
	end

	-- Ensure that anyone using this module is not indexing nil with a typo. I can already feel the time saved
	setmetatable(valModule, {
		__index = function(_, index)
			error(`Invalid ValidationConfig {index} used on the module {testEnum}`)
		end,
	})

	-- Ensure all module parameters are the expected types
	if typeof(valModule.fflag) ~= "function" or typeof(valModule.fflag()) ~= "boolean" then
		error(`Invalid FFlag config in {testEnum}`)
	end
	if typeof(valModule.is_quality) ~= "boolean" then
		error(`Invalid IS_QUALITY config in {testEnum}`)
	end
	tableOnlyHasExistingEnums(testEnum, valModule.categories, "UploadCategory")
	tableOnlyHasExistingEnums(testEnum, valModule.required_data, "SharedDataMember")
	tableOnlyHasExistingEnums(testEnum, valModule.prereq_tests, "ValidationModule")

	preloads[testEnum] = valModule
end

function ValidationModuleLoader.getValidationModule(testEnum: string): Types.PreloadedValidationModule
	if preloads[testEnum] == nil then
		error(`{testEnum} does not exist in the preload table.`)
	end

	return preloads[testEnum]
end

return ValidationModuleLoader
