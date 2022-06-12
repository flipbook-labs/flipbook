local flipbook = script:FindFirstAncestor("flipbook")

local Component = require(script.Parent.Component)
local Roact = require(flipbook.Packages.Roact)
local useTailwind = require(flipbook.Hooks.useTailwind)

local childNode1 = {
	name = "Button",
	icon = "story",
}

local childNode2 = {
	name = "Toggle",
	icon = "story",
}

local childNode3 = {
	name = "Radio",
	icon = "story",
}

local directoryNode1 = {
	name = "Files",
	icon = "folder",
	children = {
		childNode1,
		childNode2,
		childNode3,
	},
}

local storybookNode = {
	name = "Storybook",
	icon = "storybook",
	children = {
		directoryNode1,
	},
}

return function(target)
	local handle = Roact.mount(
		Roact.createElement("Frame", {
			BackgroundColor3 = useTailwind("gray-200"),
			Size = UDim2.fromScale(1, 1),
		}, {
			Container = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0, 100),
				Size = UDim2.fromOffset(236, 0),
			}, {
				Node = Roact.createElement(Component, {
					activeNode = nil,
					node = storybookNode,
					onClick = function() end,
				}),
			}),
		}),
		target
	)

	return function()
		Roact.unmount(handle)
	end
end
