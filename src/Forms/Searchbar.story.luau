local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local Searchbar = require("./Searchbar")

local stories = {}

stories.Primary = React.createElement(ContextProviders, {
	plugin = MockPlugin.new(),
}, {
	Searchbar = React.createElement(Searchbar),
})

return {
	summary = "Searchbar used to search for components",
	controls = {},
	stories = stories,
}
