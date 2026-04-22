local Foundation = require("@rbxpkg/Foundation")
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
				LayoutOrder = 1,
				sizeConstraint = {
					MinSize = Vector2.new(150, 0),
					MaxSize = Vector2.new(400, math.huge),
				},
			}, {
				Searchbar = React.createElement(Foundation.SearchInput, {
					size = Foundation.Enums.InputSize.Small,
					width = UDim.new(0, 300),
					text = "",
					shape = Foundation.Enums.SearchInputShape.Rounded,
					onChanged = function() end,
				}),
			}),

			Primary = React.createElement(Group, {
				fillDirection = Enum.FillDirection.Vertical,
				LayoutOrder = 2,
			}, {
				Topbar = React.createElement(Panel, {
					LayoutOrder = 1,
				}, {
					Icon = React.createElement(Foundation.Icon, {
						name = Foundation.Enums.IconName.Tilt,
					}),
				}),

				StoryViewport = React.createElement(Panel, {
					LayoutOrder = 2,
				}, {
					Icon = React.createElement(Foundation.Icon, {
						name = Foundation.Enums.IconName.BookOpen,
					}),
				}),

				StoryControls = React.createElement(Panel, {
					LayoutOrder = 3,
				}, {
					Icon = React.createElement(Foundation.Icon, {
						name = Foundation.Enums.IconName.Gear,
					}),
				}),
			}),

			Logs = React.createElement(Panel, {
				LayoutOrder = 3,
			}, {
				Text = React.createElement(Foundation.Text, {
					tag = "auto-xy text-body-medium content-default",
					Text = "Logs go here",
				}),
			}),
		})
	end,
}
