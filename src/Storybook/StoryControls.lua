local React = require("@pkg/React")

local useTheme = require("@root/Common/useTheme")
local InputField = require("@root/Forms/InputField")
local Checkbox = require("@root/Forms/Checkbox")
local Dropdown = require("@root/Forms/Dropdown")

local e = React.createElement

type Props = {
	controls: { [string]: any },
	setControl: (key: string, value: any) -> (),
	layoutOrder: number?,
}

local function StoryControls(props: Props)
	local theme = useTheme()

	local controls = {}
	for key, value in props.controls do
		local function setControl(newValue: any)
			props.setControl(key, newValue)
		end

		local option
		if typeof(value) == "boolean" then
			option = React.createElement(Checkbox, {
				initialState = value,
				onStateChange = setControl,
			})
		elseif typeof(value) == "table" then
			option = React.createElement(Dropdown, {
				default = value[1],
				options = value,
				onOptionChange = setControl,
			})
		else
			option = React.createElement(InputField, {
				placeholder = value,
				onTextChange = setControl,
				onSubmit = setControl,
			})
		end

		controls[key] = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Layout = React.createElement("UIListLayout", {
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

			ControlsFragment = React.createElement(React.Fragment, nil, controls),
		}),
	})
end

return StoryControls
