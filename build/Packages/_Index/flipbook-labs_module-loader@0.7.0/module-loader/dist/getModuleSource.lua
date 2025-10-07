local function getModuleSource(moduleScript: ModuleScript): string
	local success, result = pcall(function()
		return moduleScript.Source
	end)

	return if success then result else ""
end

return getModuleSource
