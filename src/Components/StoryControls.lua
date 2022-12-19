local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)
local types = require(flipbook.types)
local Checkbox = require(flipbook.Components.Fields.Checkbox)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
	controls: { types.StoryControl },
}

local function StoryControls(props: Props, hooks: any)
	local theme = useTheme(hooks)

	local controls = {}
	controls.Layout = e("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = theme.padding,
	})
	for index, control in props.controls do
		local option
		if typeof(control.value) == "boolean" then
			option = Roact.createElement(Checkbox, {
				initialState = control.value,
			})
		end

		controls[control.name] = e("Frame", {
			LayoutOrder = index,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Name = e("TextLabel", {
				Text = control.name,
				Size = UDim2.fromScale(1 / 2, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Font = theme.font,
				TextColor3 = theme.text,
				TextSize = theme.textSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),

			Option = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1 / 2, 0),
				Position = UDim2.fromScale(1 / 2, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, option),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = theme.padding,
		}),

		Title = e("TextLabel", {
			LayoutOrder = 1,
			Text = "Controls",
			Font = theme.headerFont,
			TextColor3 = theme.text,
			TextSize = theme.headerTextSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}),

		Controls = e("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, controls),
	})
end

return hook(StoryControls)
