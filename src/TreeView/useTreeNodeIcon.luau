local Foundation = require("@rbxpkg/Foundation")

local assets = require("@root/assets")
local types = require("./types")

local useTokens = Foundation.Hooks.useTokens

type TreeNodeIcon = types.TreeNodeIcon

type Sprite = {
	Image: string,
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2,
}

local function useTreeNodeIcon(icon: TreeNodeIcon): (Sprite, Color3)
	local tokens = useTokens()

	if icon == types.TreeNodeIcon.Story then
		return assets.Component, tokens.Color.Extended.Green.Green_800.Color3
	elseif icon == types.TreeNodeIcon.Storybook then
		return assets.Storybook, tokens.Color.Extended.White.White_50.Color3
	elseif icon == types.TreeNodeIcon.Folder then
		return assets.Folder, tokens.Color.Extended.Purple.Purple_800.Color3
	elseif icon == types.TreeNodeIcon.Alert then
		return assets.Alert, tokens.Color.ActionAlert.Background.Color3
	else
		return assets.Folder, tokens.Color.Extended.White.White_50.Color3
	end
end

return useTreeNodeIcon
