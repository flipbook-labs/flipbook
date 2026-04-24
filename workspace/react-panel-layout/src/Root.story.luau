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
			Sidebar = React.createElement(Group, {
				LayoutOrder = 1,
			}, {
				Explorer = React.createElement(Panel, {
					LayoutOrder = 1,
				}, {
					Searchbar = React.createElement(Foundation.SearchInput, {
						size = Foundation.Enums.InputSize.Small,
						width = UDim.new(0, 200),
						text = "",
						shape = Foundation.Enums.SearchInputShape.Rounded,
						onChanged = function() end,
					}),
				}),
			}),

			Primary = React.createElement(Group, {
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
				Title = React.createElement(Foundation.Text, {
					tag = "auto-xy text-wrap text-align-x-left text-align-y-top text-heading-medium content-emphasis",
					LayoutOrder = 1,
					Text = "Logs",
				}),

				Text = React.createElement(Foundation.Text, {
					tag = "auto-xy text-wrap text-align-x-left text-align-y-top text-body-medium content-default",
					LayoutOrder = 2,
					Text = ("Line\n"):rep(40),
				}),
			}),
		})
	end,
}
