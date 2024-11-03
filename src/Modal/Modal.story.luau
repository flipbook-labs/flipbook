local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local Modal = require("./Modal")
local useTheme = require("@root/Common/useTheme")

local function ExampleContent()
	local theme = useTheme()

	local paragraphs = {}
	for i = 1, 2 do
		paragraphs[`Paragraph{i}`] = React.createElement("TextLabel", {
			LayoutOrder = i,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Text = "Occaecat commodo fugiat fugiat minim adipisicing esse duis anim ea elit enim officia ut. Deserunt exercitation sit nisi ullamco labore in mollit nostrud Lorem. Commodo laboris est qui enim aute ea dolore voluptate dolor nulla. Quis duis ut voluptate magna dolore pariatur mollit in occaecat aute. Adipisicing magna mollit non sit eiusmod reprehenderit id officia officia non dolore aute voluptate ex.",
			TextWrapped = true,
			Font = theme.font,
			TextColor3 = theme.text,
			TextSize = theme.textSize,
			LineHeight = 1.5,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = theme.padding,
		}),
	}, paragraphs)
end

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			Model = React.createElement(Modal, {
				title = "Example Modal",
				onClose = function()
					print("close")
				end,
			}, {
				Content = React.createElement(ExampleContent),
			}),
		})
	end,
}
