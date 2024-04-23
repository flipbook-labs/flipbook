local React = require("@pkg/React")
local Searchbar = require("./Searchbar")

local stories = {}

stories.Primary = React.createElement(Searchbar)

return {
	summary = "Searchbar used to search for components",
	controls = {},
	stories = stories,
}
