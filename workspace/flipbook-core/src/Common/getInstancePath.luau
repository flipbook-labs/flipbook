local PATH_SEPARATOR = "/"

local function getInstancePath(instance: Instance, pathSeparator: string?): string
	local separator = if pathSeparator then pathSeparator else PATH_SEPARATOR

	local path = {}
	local current = instance

	while current and current.Parent ~= nil do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end

	return table.concat(path, separator)
end

return getInstancePath
