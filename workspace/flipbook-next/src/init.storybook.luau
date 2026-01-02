local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local FoundationProvider = Foundation.FoundationProvider

return {
	name = "FlipbookNext",
	mapStory = function(Story)
		return function(storyProps)
			return React.createElement(FoundationProvider, nil, {
				Story = React.createElement(Story, storyProps)
			})
		end
	end,
	packages = { React = React, ReactRoblox = ReactRoblox },
	storyRoots = { script.Parent }
}
