local assets = require("@root/assets")
local useTheme = require("@root/Common/useTheme")
local types = require("./types")

type TreeNodeIcon = types.TreeNodeIcon

type Sprite = {
	Image: string,
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2,
}

local function useTreeNodeIcon(icon: TreeNodeIcon): (Sprite, Color3)
	local theme = useTheme()

	if icon == types.TreeNodeIcon.Story then
		return assets.Component, theme.story
	elseif icon == types.TreeNodeIcon.Storybook then
		return assets.Storybook, theme.textFaded
	elseif icon == types.TreeNodeIcon.Folder then
		return assets.Folder, theme.directory
	else
		return assets.Folder, theme.textFaded
	end
end

return useTreeNodeIcon
