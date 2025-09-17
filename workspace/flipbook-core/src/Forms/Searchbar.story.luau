local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local Searchbar = require("./Searchbar")

return {
	summary = "Searchbar used to search for components",
	controls = {},
	story = React.createElement(ContextProviders, {
		plugin = MockPlugin.new() :: any,
	}, {
		Searchbar = React.createElement(Searchbar),
	}),
}
