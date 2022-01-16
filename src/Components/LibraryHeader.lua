local hook = require(script.Parent.Parent.hook)
local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.styles)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

local function LibraryHeader(_, hooks: any)
	local theme = useTheme(hooks)

	return Roact.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 102),
		Size = UDim2.fromScale(1, 0),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Library = Roact.createElement(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				Font = Enum.Font.GothamBlack,
				LayoutOrder = 1,
				Text = "L I B R A R Y",
				TextColor3 = theme.stroke,
				TextSize = 14,
			})
		),

		Divider = Roact.createElement("Frame", {
			BackgroundColor3 = theme.stroke,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 1),
		}),
	})
end

return hook(LibraryHeader)
