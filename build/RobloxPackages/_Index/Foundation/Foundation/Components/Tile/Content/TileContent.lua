local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local useTileLayout = require(Foundation.Components.Tile.useTileLayout)
local withDefaults = require(Foundation.Utility.withDefaults)
local useTokens = require(Foundation.Providers.Style.useTokens)
local View = require(Foundation.Components.View)

type TileContentProps = {
	children: React.ReactNode?,
	LayoutOrder: number?,
}

local defaultProps = {
	LayoutOrder = 2,
}

local function TileContent(tileContentProps: TileContentProps)
	local props = withDefaults(tileContentProps, defaultProps)

	local tokens = useTokens()
	local tileLayout = useTileLayout()

	return React.createElement(View, {
		tag = "size-full col gap-small align-y-top",
		flexItem = {
			FlexMode = Enum.UIFlexMode.Shrink,
		},
		padding = if tileLayout.isContained then tokens.Padding.Small else nil,
		LayoutOrder = props.LayoutOrder,
	}, props.children)
end

return TileContent
