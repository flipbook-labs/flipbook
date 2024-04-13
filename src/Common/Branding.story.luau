local flipbook = script:FindFirstAncestor("flipbook")

local Branding = require(script.Parent.Branding)
local React = require(flipbook.Packages.React)

return {
	summary = "Icon and Typography for flipbook",
	controls = {},
	story = React.createElement(Branding),
}
