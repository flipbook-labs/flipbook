local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local Group = require("@root/Group")
local Panel = require("@root/Panel")

local Root = require("./Root")

return {
	story = function()
		return React.createElement(Foundation.ScrollView, {
			tag = "size-full col gap-large padding-medium",
			scroll = {
				CanvasSize = UDim2.fromScale(1, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
			},
			layout = {
				FillDirection = Enum.FillDirection.Vertical,
			},
		}, {
			FlipbookLayout = React.createElement(Foundation.View, {
				tag = "size-full auto-y col gap-medium",
				LayoutOrder = 1,
			}, {
				Label = React.createElement(Foundation.Text, {
					tag = "auto-xy text-heading-small content-emphasis",
					Text = "Flipbook Layout",
					LayoutOrder = 1,
				}),

				PanelLayout = React.createElement(Root, {
					fillDirection = Enum.FillDirection.Horizontal,
					LayoutOrder = 1,
				}, {
					Sidebar = React.createElement(Group, {
						id = "sidebar",
						minSize = Vector2.new(100, 100),
						LayoutOrder = 1,
					}, {
						Explorer = React.createElement(Panel, {
							id = "explorer",
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
						id = "primary",
						flexMode = Enum.UIFlexMode.Fill,
						LayoutOrder = 2,
					}, {
						StoryViewport = React.createElement(Panel, {
							id = "story-viewport",
							flexMode = Enum.UIFlexMode.Fill,
							LayoutOrder = 1,
						}, {
							Icon = React.createElement(Foundation.Icon, {
								name = Foundation.Enums.IconName.BookOpen,
							}),
						}),

						StoryControls = React.createElement(Panel, {
							id = "story-controls",
							maxSize = Vector2.new(math.huge, 400),
							LayoutOrder = 2,
						}, {
							Icon = React.createElement(Foundation.Icon, {
								name = Foundation.Enums.IconName.Gear,
							}),
						}),
					}),

					Logs = React.createElement(Panel, {
						id = "logs",
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
				}),
			}),
		})
	end,
}
