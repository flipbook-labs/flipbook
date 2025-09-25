local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useMemo = React.useMemo
local e = React.createElement

type Props = {
	controls: { [string]: any },
	setControl: (key: string, value: any) -> (),
	layoutOrder: number?,
}

local function StoryControls(props: Props)
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
		local option: React.Node
		if controlType == "boolean" then
			option = React.createElement(Foundation.Checkbox, {
				label = "label",
				isChecked = control.value,
				onActivated = setControl,
			})
		elseif controlType == "table" then
			option = React.createElement(Foundation.Dropdown.Root, {
				label = "label",
				items = control.value,
				onItemChanged = setControl,
			})
		elseif controlType == "number" or controlType == "string" then
			option = React.createElement(Foundation.TextInput, {
				label = "label",
				text = control.value,
				onChanged = setControl,
			})
		else
			option = React.createElement(Foundation.Text, {
				tag = "auto-xy text-label-medium text-truncate content-system-alert",
				Text = `ERR: Controls of type "{controlType}" are unsupported`,
			})
		end

		controlElements[control.name] = e(Foundation.View, {
			tag = {
				["size-full-0 auto-y row gap-medium padding-small align-y-center"] = true,
				["bg-surface-100"] = index % 2 ~= 0,
				["bg-surface-200"] = index % 2 == 0,
			},
			LayoutOrder = index,
		}, {
			Name = e(Foundation.Text, {
				tag = "auto-y text-label-medium text-truncate text-align-x-left",
				Text = control.name,
				Size = UDim2.fromScale(1 / 4, 0),
				LayoutOrder = nextLayoutOrder(),
			}),

			OptionWrapper = e(Foundation.View, {
				tag = "size-full-0 auto-y shrink",
				LayoutOrder = nextLayoutOrder(),
			}, {
				-- Keying by the identity of sortedControls fixes a bug where
				-- the options visually do not update when two stories have the
				-- exact same controls
				[`Option_{sortedControls}`] = option,
			}),
		})
	end

	return e(Foundation.View, {
		tag = "size-full-0 auto-y col gap-medium padding-medium",
		LayoutOrder = props.layoutOrder,
	}, {
		Title = e(Foundation.Text, {
			tag = "auto-xy text-heading-small text-align-x-left",
			Text = "Controls",
			LayoutOrder = nextLayoutOrder(),
		}),

		Controls = e(Foundation.View, {
			tag = "size-full-0 auto-y col",
			LayoutOrder = nextLayoutOrder(),
		}, controlElements),
	})
end

return StoryControls
