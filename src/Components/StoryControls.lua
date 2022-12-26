local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)
local InputField = require(flipbook.Components.InputField)
local Checkbox = require(flipbook.Components.Fields.Checkbox)
local Dropdown = require(flipbook.Components.Fields.Dropdown)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
	controls: { [string]: any },
	setControl: (key: string, value: any) -> (),
}

local function StoryControls(props: Props, hooks: any)
	local theme = useTheme(hooks)

	local controls = {}
	for key, value in props.controls do
		local function setControl(newValue: any)
			props.setControl(key, newValue)
		end

		local option
		if typeof(value) == "boolean" then
			option = Roact.createElement(Checkbox, {
				initialState = value,
				onStateChange = setControl,
			})
		elseif typeof(value) == "table" then
			option = Roact.createElement(Dropdown, {
				default = value[1],
				options = value,
				onOptionChange = setControl,
			})
		else
			option = Roact.createElement(InputField, {
				placeholder = value,
				onTextChange = setControl,
			})
		end

		controls[key] = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
			}),

			Name = e("TextLabel", {
				Text = key,
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
		}, {
			Layout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.Name,
				Padding = theme.padding,
			}),

			ControlsFragment = Roact.createFragment(controls),
		}),
	})
end

return hook(StoryControls)
