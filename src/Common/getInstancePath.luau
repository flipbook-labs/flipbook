local PATH_SEPARATOR = "/"

local function getInstancePath(instance: Instance, pathSeparator: string?): string
	pathSeparator = if pathSeparator then pathSeparator else PATH_SEPARATOR
	assert(pathSeparator, "Luau")

	local path = {}
	local current = instance

	while current and current.Parent ~= nil do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end

	return table.concat(path, "/")
end

return getInstancePath
