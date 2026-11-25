local Storyteller = require("@pkg/Storyteller")

local ControlType = Storyteller.ControlType

type StoryControls = Storyteller.StoryControls
type StoryControlsSchema = Storyteller.StoryControlsSchema

local VALUE_TYPES: { [string]: string } = {
	[ControlType.Boolean] = "boolean",
	[ControlType.Color] = "Color3",
	[ControlType.Date] = "DateTime",
	[ControlType.Number] = "number",
	[ControlType.Object] = "Instance",
	[ControlType.Slider] = "number",
	[ControlType.String] = "string",
}

-- For each control that picks from a list, whether its value is an array of
-- picked items or one item. Other kinds of control aren't in this table.
local PICKS_SEVERAL_ITEMS: { [string]: boolean } = {
	[ControlType.Check] = true,
	[ControlType.MultiSelect] = true,
	[ControlType.Radio] = false,
	[ControlType.Select] = false,
}

local function assertValueType(value: unknown, expectedType: string, path: string)
	if typeof(value) ~= expectedType then
		error(`{path} must be a {expectedType}, got {typeof(value)}`, 0)
	end
end

local function assertDeclaredItem(value: unknown, items: { unknown }, path: string)
	if table.find(items, value) == nil then
		local names: { string } = {}
		for _, item in items do
			table.insert(names, tostring(item))
		end
		error(`{path} must be one of [{table.concat(names, ", ")}], got {value}`, 0)
	end
end

local function assertDeclaredItems(value: unknown, items: { unknown }, path: string)
	assertValueType(value, "table", path)

	for index, item in value :: { [unknown]: unknown } do
		if typeof(index) ~= "number" then
			error(`{path} must be an array of declared control items`, 0)
		end
		assertDeclaredItem(item, items, `{path}[{index}]`)
	end
end

local function assertControlValue(value: unknown, definition: unknown, path: string)
	-- A schema can give a control's default value in place of its definition.
	-- The new value then has to have the same type as the default.
	if typeof(definition) ~= "table" then
		assertValueType(value, typeof(definition), path)
		return
	end

	local control = definition :: { [string]: unknown }
	local controlType = control.type :: string
	local picksSeveralItems = PICKS_SEVERAL_ITEMS[controlType]
	local valueType = VALUE_TYPES[controlType]

	if picksSeveralItems == true then
		assertDeclaredItems(value, control.items :: { unknown }, path)
	elseif picksSeveralItems == false then
		assertDeclaredItem(value, control.items :: { unknown }, path)
	elseif valueType then
		assertValueType(value, valueType, path)
	else
		error(`{path} uses unsupported Story control type "{controlType}"`, 0)
	end
end

--[[
	Agents set a story's controls by name, with the same values a story would
	use, such as a Color3 or an EnumItem. This checks that the story declares
	each control, that each value has the control's type, and that anything
	picked from a list is in it. If something doesn't match, it errors with the
	control's name and what was expected. Otherwise it returns the same table,
	typed as story controls.

	Numbers outside a control's range are allowed here, since Storyteller clamps
	them when the story renders.
]]
local function parseControlValues(schema: StoryControlsSchema, controls: { [string]: unknown }): StoryControls
	for name, value in controls do
		local definition = schema[name]
		if definition == nil then
			error(`controls.{name} is not declared by the mounted Story`, 0)
		end
		assertControlValue(value, definition, `controls.{name}`)
	end

	return controls :: StoryControls
end

return parseControlValues
