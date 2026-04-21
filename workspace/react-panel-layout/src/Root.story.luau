local React = require("@pkg/React")

local Group = require("@root/Group")
local Panel = require("@root/Panel")

local Root = require("./Root")

return {
	story = function()
		return React.createElement(Root, {
			fillDirection = Enum.FillDirection.Horizontal,
		}, {
			Sidebar = React.createElement(Panel, {
				id = "sidebar",
				sizeConstraint = {
					MinSize = Vector2.new(150, 0),
					MaxSize = Vector2.new(300, math.huge),
				},
			}),

			Primary = React.createElement(Group, {
				id = "primary",
			}, {
				Topbar = React.createElement(Panel, {
					id = "topbar",
				}),

				StoryViewport = React.createElement(Panel, {
					id = "story-viewport",
				}),

				StoryControls = React.createElement(Panel, {
					id = "story-controls",
				}),
			}),

			Logs = React.createElement(Panel, {
				id = "logs",
			}),
		})
	end,
}
