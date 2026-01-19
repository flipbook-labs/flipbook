local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState

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
	local activeItemIds, setActiveItemIds = useState({} :: { ItemId })

	local items: { Foundation.DropdownItem } = useMemo(function()
		return Sift.List.map(props.controlSchema.items, function(value)
			local id = getItemId(value)
			local isChecked = table.find(activeItemIds, id) ~= nil

			local item: Foundation.DropdownItem = {
				id = id,
				text = if typeof(props.controlSchema.tostring) == "function"
					then props.controlSchema.tostring(value)
					else tostring(value),
				isChecked = isChecked,
			}

			return item
		end)
	end, { props.controlSchema, activeItemIds } :: { unknown })

	local onItemChanged = useCallback(function(itemId: ItemId)
		setActiveItemIds(function(prev)
			local new = table.clone(prev)

			local index = table.find(new, tostring(itemId))
			if index then
				table.remove(new, index)
			else
				table.insert(new, tostring(itemId))
			end

			return new
		end)
	end, { props.controlValue, props.onChanged } :: { unknown })

	local value = useMemo(function(): ItemId?
		-- It would have been nice to display a comma-seperated list of the
		-- checked values, but `Dropdown.Root` only accepts an ItemId for the
		-- `value` prop. So we're opting instead to show the first selected
		-- value
		if #activeItemIds > 0 then
			return activeItemIds[1]
		end

		return nil
	end, { activeItemIds, items } :: { unknown })

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

return MultiSelectControl
