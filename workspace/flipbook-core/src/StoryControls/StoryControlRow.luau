local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Storyteller = require("@pkg/Storyteller")

local BooleanControl = require("@root/StoryControls/ControlElements/BooleanControl")
local CheckControl = require("@root/StoryControls/ControlElements/CheckControl")
local ColorControl = require("@root/StoryControls/ControlElements/ColorControl")
local DateControl = require("@root/StoryControls/ControlElements/DateControl")
local MultiSelectControl = require("@root/StoryControls/ControlElements/MultiSelectControl")
local NumberControl = require("@root/StoryControls/ControlElements/NumberControl")
local ObjectControl = require("@root/StoryControls/ControlElements/ObjectControl")
local RadioControl = require("@root/StoryControls/ControlElements/RadioControl")
local SelectControl = require("@root/StoryControls/ControlElements/SelectControl")
local SliderControl = require("@root/StoryControls/ControlElements/SliderControl")
local StoryControlsContext = require("@root/StoryControls/StoryControlsContext")
local StringControl = require("@root/StoryControls/ControlElements/StringControl")

local ControlType = Storyteller.ControlType
type ControlType = Storyteller.ControlType

local e = React.createElement
local useCallback = React.useCallback
local useSignalState = ReactCharm.useSignalState

local useStoryControls = StoryControlsContext.useStoryControls

export type Props = {
	controlName: string,
	control: Storyteller.StoryControl,
	LayoutOrder: number?,
}

local function StoryControlRow(props: Props)
	local storyControls = useStoryControls()
	local controlType = props.control.type
	local shouldCoerceToNumber = controlType == ControlType.Number or controlType == ControlType.Slider

	local setControl = useCallback(function(newValue: any)
		if shouldCoerceToNumber then
			local newValueAsNumber = tonumber(newValue)

			if newValueAsNumber ~= nil then
				newValue = newValueAsNumber
			end
		end

		storyControls.setControl(props.controlName, newValue)
	end, { props.controlName, shouldCoerceToNumber, storyControls } :: { unknown })

	local controlValue = useSignalState(storyControls.getControlValue(props.controlName))

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
	elseif controlType == ControlType.Object then
		controlElement = e(ObjectControl, {
			controlSchema = props.control :: Storyteller.ObjectControl,
			controlValue = controlValue :: Instance?,
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
			controlValue = (controlValue :: { Storyteller.StoryControlValue }) or {},
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
		controlElement = e(MultiSelectControl, {
			controlSchema = props.control :: Storyteller.MultiSelectControl,
			controlValue = (controlValue :: { Storyteller.StoryControlValue }) or {},
			onChanged = setControl,
		})
	elseif controlType == ControlType.Radio then
		controlElement = e(RadioControl, {
			controlSchema = props.control :: Storyteller.SelectControl,
			controlValue = controlValue :: Storyteller.StoryControlValue,
			onChanged = setControl,
		})
	elseif controlType == ControlType.Select then
		controlElement = e(SelectControl, {
			controlSchema = props.control :: Storyteller.SelectControl,
			controlValue = controlValue :: Storyteller.StoryControlValue,
			onChanged = setControl,
		})
	elseif controlType == ControlType.Slider then
		controlElement = e(SliderControl, {
			controlSchema = props.control :: Storyteller.SliderControl,
			controlValue = controlValue :: number,
			onChanged = setControl,
		})
	end

	return e(Foundation.View, {
		LayoutOrder = props.LayoutOrder,
		tag = "auto-y col size-full-0",
	}, {
		Content = e(Foundation.View, {
			LayoutOrder = 1,
			tag = "align-y-center auto-y gap-small padding-small row size-full-0",
		}, {
			Title = e(Foundation.Text, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.2, 0),
				Text = props.controlName,
				tag = "auto-y text-align-x-left text-label-small",
			}),

			Option = e(Foundation.View, {
				LayoutOrder = 2,
				tag = "align-x-left auto-y fill row",
			}, {
				-- Keying by control schema identity ensures the option UI
				-- refreshes when switching between stories with equivalent
				-- control names.
				[`Option_{props.control}`] = controlElement,
			}),
		}),
	})
end

return StoryControlRow
