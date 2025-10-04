local Foundation = require("@rbxpkg/Foundation")

local types = require("./types")

local useTokens = Foundation.Hooks.useTokens

local IconName = Foundation.Enums.IconName

type TreeNodeIcon = types.TreeNodeIcon

local function useTreeNodeIcon(icon: TreeNodeIcon): (string, Foundation.ColorStyle)
	local tokens = useTokens()

	if icon == types.TreeNodeIcon.Story then
		return IconName.DiamondSimplified, tokens.Color.Extended.Green.Green_500
	elseif icon == types.TreeNodeIcon.Storybook then
		return IconName.SquareBooks, tokens.Color.Content.Default
	elseif icon == types.TreeNodeIcon.Folder then
		return IconName.FileBox, tokens.Color.Extended.Purple.Purple_500
	elseif icon == types.TreeNodeIcon.Alert then
		return IconName.TriangleExclamation, tokens.Color.ActionAlert.Foreground
	end

	return "", tokens.Color.Content.Default
end

return useTreeNodeIcon
