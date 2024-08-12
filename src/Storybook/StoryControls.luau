local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Checkbox = require("@root/Forms/Checkbox")
local Dropdown = require("@root/Forms/Dropdown")
local InputField = require("@root/Forms/InputField")
local useTheme = require("@root/Common/useTheme")

local useMemo = React.useMemo
local e = React.createElement

type Props = {
	controls: { [string]: any },
	setControl: (key: string, value: any) -> (),
	layoutOrder: number?,
}

local function StoryControls(props: Props)
	local theme = useTheme()

	local sortedControls: { { name: string, value: any } } = useMemo(function()
		local result = {}

		for _, entry in Sift.Dictionary.entries(props.controls) do
			table.insert(result, {
				name = entry[1],
				value = entry[2],
			})
		end

		return Sift.List.sort(result, function(a, b)
			return a.name < b.name
		end)
	end, { props.controls })

	local controlElements: { [string]: React.Node } = {}
	for index, control in sortedControls do
		local function setControl(newValue: any)
			local newValueAsNum = tonumber(newValue)
			if newValueAsNum then
				newValue = newValueAsNum
			end

			props.setControl(control.name, newValue)
		end

		local controlType = typeof(control.value)
		local option
		if controlType == "boolean" then
			option = React.createElement(Checkbox, {
				initialState = control.value,
				onStateChange = setControl,
			})
		elseif controlType == "table" then
			option = React.createElement(Dropdown, {
				default = control.value[1],
				options = control.value,
				onOptionChange = setControl,
			})
		elseif controlType == "number" or controlType == "string" then
			option = React.createElement(InputField, {
				placeholder = control.value,
				onSubmit = setControl,
			})
		else
			option = React.createElement("TextLabel", {
				Text = `ERR: Controls of type "{controlType}" are unsupported`,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.font,
				TextColor3 = theme.alert,
				TextSize = theme.textSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
		end

		controlElements[control.name] = e("Frame", {
			LayoutOrder = index,
			BackgroundColor3 = theme.background,
			BackgroundTransparency = if index % 2 == 0 then 1 else 0,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = theme.padding,
			}),

			Padding = e("UIPadding", {
				PaddingTop = theme.padding,
				PaddingRight = theme.padding,
				PaddingBottom = theme.padding,
				PaddingLeft = theme.padding,
			}),

			Name = e("TextLabel", {
				LayoutOrder = 1,
				Text = control.name,
				Size = UDim2.fromScale(1 / 4, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Font = theme.font,
				TextColor3 = theme.text,
				TextSize = theme.textSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}),

			Option = e("Frame", {
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Flex = e("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Shrink,
				}),
			}, option),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 0.4,
		BackgroundColor3 = theme.sidebar,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 1),
	}, {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = theme.padding,
		}),

		Padding = e("UIPadding", {
			PaddingTop = theme.padding,
			PaddingRight = theme.padding,
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
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
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}, controlElements),
	})
end

return StoryControls
