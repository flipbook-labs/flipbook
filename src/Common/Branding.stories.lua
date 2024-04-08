local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Branding = require(script.Parent.Branding)

local stories = {}

stories.Primary = React.createElement(Branding)

return {
	summary = "Icon and Typography for flipbook",
	stories = stories,
}
