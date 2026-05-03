local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback
local useMemo = React.useMemo

export type Props = {
	controlSchema: Storyteller.MultiSelectControl,
	controlValue: { Storyteller.StoryControlValue },
	onChanged: (nextValue: { Storyteller.StoryControlValue }) -> (),
}

type ItemId = number | string

local function getItemId(item: unknown): ItemId
	return tostring(item)
end

local function getItemText(schema: Storyteller.MultiSelectControl, value: Storyteller.StoryControlValue): string
	return if typeof(schema.tostring) == "function" then schema.tostring(value) else tostring(value)
end

local function MultiSelectControl(props: Props)
	local getItemFromId = useCallback(function(id: ItemId): Storyteller.StoryControlValue?
		for _, value in props.controlSchema.items do
			if getItemId(value) == id then
				return value
			end
		end
		return nil
	end, { props.controlSchema.items } :: { unknown })

	local onItemChanged = useCallback(function(itemId: ItemId)
		local itemIdStr = tostring(itemId)
		local new = {}
		local found = false
		for _, value in props.controlValue do
			if getItemId(value) == itemIdStr then
				found = true -- deselect: skip
			else
				table.insert(new, value)
			end
		end
		if not found then
			local item = getItemFromId(itemIdStr)
			if item ~= nil then
				table.insert(new, item)
			end
		end
		props.onChanged(new)
	end, { props.controlValue, props.onChanged, getItemFromId } :: { unknown })

	local items: { Foundation.DropdownItem } = useMemo(function()
		return Sift.List.map(props.controlSchema.items, function(value)
			local id = getItemId(value)
			local isChecked = table.find(props.controlValue, value) ~= nil

			local item: Foundation.DropdownItem = {
				id = id,
				text = getItemText(props.controlSchema, value),
				isChecked = isChecked,
			}

			return item
		end)
	end, { props.controlSchema, props.controlValue } :: { unknown })

	local placeholder = useMemo(function(): string
		if #props.controlValue == 0 then
			return "Make a selection..."
		end
		local parts = {}
		for _, value in props.controlValue do
			table.insert(parts, getItemText(props.controlSchema, value))
		end
		return table.concat(parts, ", ")
	end, { props.controlValue, props.controlSchema } :: { unknown })

	return e(Foundation.Dropdown.Root, {
		items = items,
		label = "",
		onItemChanged = onItemChanged,
		placeholder = placeholder,
		size = Foundation.Enums.InputSize.Small,
		width = UDim.new(1, 0),
	})
end

return React.memo(MultiSelectControl)
