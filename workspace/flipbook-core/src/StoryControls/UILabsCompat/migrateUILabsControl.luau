local Sift = require("@pkg/Sift")

local ControlType = require("@root/StoryControls/Enums/ControlType")
local UILabsTypes = require("@root/StoryControls/UILabsCompat/UILabsTypes")
local types = require("@root/StoryControls/types")

type Control<T> = UILabsTypes.Control<T>

local function migrateUILabsControl(control: Control<any>): types.StoryControl?
	if control.Type == "String" then
		local migrated: types.StringControl = {
			control = ControlType.String,
			default = control.ControlValue,
		}
		return migrated
	elseif control.Type == "Number" then
		local migrated: types.NumberControl = {
			control = ControlType.Number,
			default = control.ControlValue,
			range = if control.Min and control.Max then NumberRange.new(control.Min, control.Max) else nil,
			step = control.Step,
		}
		return migrated
	elseif control.Type == "Boolean" then
		local migrated: types.BooleanControl = {
			control = ControlType.Boolean,
			default = control.ControlValue,
		}
		return migrated
	elseif control.Type == "Choose" then
		local migrated: types.SelectControl = {
			control = ControlType.Select,
			options = control.List,
			default = control.List[control.DefIndex],
		}
		return migrated
	elseif control.Type == "EnumList" then
		local migrated: types.SelectControl = {
			control = ControlType.Select,
			options = Sift.List.sort(Sift.Dictionary.values(control.List)),
			default = control.List[control.DefIndex],
		}
		return migrated
	elseif control.Type == "Slider" then
		local migrated: types.SliderControl = {
			control = ControlType.Slider,
			default = control.ControlValue,
			range = NumberRange.new(control.Min, control.Max),
			step = control.Step,
		}
		return migrated
	elseif control.Type == "RGBA" then
		local migrated: types.ColorControl = {
			control = ControlType.Color,
			default = control.ControlValue.Color,
		}
		return migrated
	elseif control.Type == "Object" then
		return nil
	end
	return nil
end

return migrateUILabsControl
