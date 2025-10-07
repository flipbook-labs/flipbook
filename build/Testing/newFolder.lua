local function newFolder(children: { [string]: Instance }): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Root"

	for name, child in pairs(children) do
		child.Name = name
		child.Parent = folder
	end

	return folder
end

return newFolder
