local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local Types = require(Foundation.Components.Types)
type Padding = Types.Padding

local React = require(Packages.React)

local TileLayoutContext = require(script.Parent.TileLayoutContext)

type TileLayout = {
	fillDirection: Enum.FillDirection,
	isContained: boolean,
}

local useTileLayout = function(): TileLayout
	return React.useContext(TileLayoutContext)
end

return useTileLayout
