local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

return {
	story = function(props: Storyteller.StoryProps)
		local children: { [string]: React.Node } = {}

		for key, value in props do
			children[key] = React.createElement(Foundation.Text, {
				tag = "auto-xy content-default text-body-large",
				Text = `- {key}: {value}`,
			})
		end

		return React.createElement(Foundation.View, {
			tag = "col gap-small",
		}, children)
	end,
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
