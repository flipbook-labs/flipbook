local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local BooleanControl = require("@root/StoryControls/ControlElements/BooleanControl")
local CheckControl = require("@root/StoryControls/ControlElements/CheckControl")
local ColorControl = require("@root/StoryControls/ControlElements/ColorControl")
local DateControl = require("@root/StoryControls/ControlElements/DateControl")
local NumberControl = require("@root/StoryControls/ControlElements/NumberControl")
local SelectControl = require("@root/StoryControls/ControlElements/SelectControl")
local StringControl = require("@root/StoryControls/ControlElements/StringControl")

local ControlType = Storyteller.ControlType

local e = React.createElement
local useCallback = React.useCallback

export type Props = {
	controlName: string,
	control: Storyteller.StoryControl,
	controls: Storyteller.StoryControls,
	setControl: (key: string, value: any) -> (),
	LayoutOrder: number?,
}

local function StoryControlRow(props: Props)
	local setControl = useCallback(function(newValue: any)
		local newValueAsNumber = tonumber(newValue)

		if newValueAsNumber ~= nil then
			newValue = newValueAsNumber
		end

		props.setControl(props.controlName, newValue)
	end, { props.controlName })

	-- TODO: I think we need hydrateControls so we can use the same defaults
	-- here as StoryContainer
	print("props.controls", props.controls)

	local controlType = props.control.type
	local controlValue: (Storyteller.StoryControlValue | { Storyteller.StoryControlValue })? =
		props.controls[props.controlName]

	local controlElement: React.Node
	if controlType == ControlType.Boolean then
		controlElement = e(BooleanControl, {
			controlSchema = props.control :: Storyteller.BooleanControl,
			controlValue = controlValue :: boolean,
			onChanged = setControl,
		})
	elseif controlType == ControlType.Number then
		controlElement = e(NumberControl, {
			controlSchema = props.control :: Storyteller.NumberControl,
			controlValue = controlValue :: number,
			onChanged = setControl,
		})
	elseif controlType == ControlType.String then
		controlElement = e(StringControl, {
			controlSchema = props.control :: Storyteller.StringControl,
			controlValue = controlValue :: string,
			onChanged = setControl,
		})
	elseif controlType == ControlType.Check then
		controlElement = e(CheckControl, {
			controlSchema = props.control :: Storyteller.CheckControl,
			controlValue = controlValue :: { Storyteller.StoryControlValue },
			onChanged = setControl,
		})
	elseif controlType == ControlType.Color then
		controlElement = e(ColorControl, {
			controlSchema = props.control :: Storyteller.ColorControl,
			controlValue = controlValue :: Color3,
			onChanged = setControl,
		})
	elseif controlType == ControlType.Date then
		controlElement = e(DateControl, {
			controlSchema = props.control :: Storyteller.DateControl,
			controlValue = controlValue :: DateTime,
			onChanged = setControl,
		})
	elseif controlType == ControlType.MultiSelect then
	elseif controlType == ControlType.Radio then
	elseif controlType == ControlType.Select then
		controlElement = e(SelectControl, {
			controlSchema = props.control :: Storyteller.SelectControl,
			controlValue = controlValue :: Storyteller.StoryControlValue,
			onChanged = setControl,
		})
	elseif controlType == ControlType.Slider then
	end

	return e(Foundation.View, {
		LayoutOrder = props.LayoutOrder,
		tag = "auto-y col size-full-0",
	}, {
		Content = e(Foundation.View, {
			LayoutOrder = 1,
			tag = "align-y-center auto-y gap-medium padding-medium row size-full-0",
		}, {
			Title = e(Foundation.Text, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.2, 0),
				Text = props.controlName,
				tag = "auto-y text-align-x-left text-label-medium",
			}),

			Option = e(Foundation.View, {
				LayoutOrder = 2,
				tag = "align-x-left auto-y fill row",
			}, {
				-- Keying by the identity of sortedControls fixes a bug where
				-- the options visually do not update when two stories have the
				-- exact same controls.
				[`Option_{props.control}`] = controlElement,
			}),
		}),
	})
end

return StoryControlRow
