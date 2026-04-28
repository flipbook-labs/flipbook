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
			table.insert(new, getItemFromId(itemIdStr))
		end
		props.onChanged(new)
	end, { props.controlValue, props.onChanged, getItemFromId } :: { unknown })

	local items: { Foundation.DropdownItem } = useMemo(function()
		return Sift.List.map(props.controlSchema.items, function(value)
			local id = getItemId(value)
			local isChecked = table.find(props.controlValue, value) ~= nil

			local item: Foundation.DropdownItem = {
				id = id,
				text = if typeof(props.controlSchema.tostring) == "function"
					then props.controlSchema.tostring(value)
					else tostring(value),
				isChecked = isChecked,
			}

			return item
		end)
	end, { props.controlSchema, props.controlValue } :: { unknown })

	local value = useMemo(function(): ItemId?
		-- It would have been nice to display a comma-seperated list of the
		-- checked values, but `Dropdown.Root` only accepts an ItemId for the
		-- `value` prop. So we're opting instead to show the first selected
		-- value
		if #props.controlValue > 0 then
			return getItemId(props.controlValue[1])
		end

		return nil
	end, { props.controlValue } :: { unknown })

	return e(Foundation.Dropdown.Root, {
		items = items,
		label = "",
		onItemChanged = onItemChanged,
		value = value,
		placeholder = "Make a selection...",
		size = Foundation.Enums.InputSize.Small,
		width = UDim.new(1, 0),

		-- TODO: Keep open while selecting options. Close when clicking outside
	})
end

return React.memo(MultiSelectControl)
