local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local DialogSize = require(Foundation.Enums.DialogSize)
type DialogSize = DialogSize.DialogSize

return React.createContext({
	size = DialogSize.Small,
	responsiveSize = DialogSize.Small,
	setResponsiveSize = function(_size: DialogSize) end,
	hasHeroMedia = false,
	setHasHeroMedia = function(_hasHeroMedia: boolean) end,
})
