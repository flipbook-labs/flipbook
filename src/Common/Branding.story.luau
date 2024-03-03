local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Branding = require(script.Parent.Branding)

return {
	summary = "Icon and Typography for flipbook",
	controls = {},
	story = React.createElement(Branding),
}
