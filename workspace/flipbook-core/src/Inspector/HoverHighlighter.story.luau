local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local HoverHighlighter = require("./HoverHighlighter")

local useRef = React.useRef

return {
	story = function()
		local hoverRef = useRef(nil :: GuiObject?)

		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			React.createElement(React.Fragment, nil, {
				HoverHighlighter = React.createElement(HoverHighlighter, {
					hoverRef = hoverRef,
				}),

				Content = React.createElement(Foundation.View, {
					tag = "auto-xy col gap-medium",
					ref = hoverRef,
				}, {
					Label = React.createElement(Foundation.Text, {
						tag = "auto-xy text-body-medium",
						Text = "Hover over me!",
						LayoutOrder = nextLayoutOrder(),
					}),

					Level1 = React.createElement(Foundation.View, {
						tag = "auto-xy padding-medium bg-surface-100",
						LayoutOrder = nextLayoutOrder(),
					}, {
						Level2 = React.createElement(Foundation.View, {
							tag = "auto-xy padding-medium bg-surface-200",
						}, {
							Level3 = React.createElement(Foundation.View, {
								tag = "auto-xy padding-medium bg-surface-300",
							}, {

								NestedLabel = React.createElement(Foundation.Text, {
									tag = "auto-xy text-body-medium",
									Text = "Hover over me too!",
								}),
							}),
						}),
					}),
				}),
			}),
		})
	end,
}
