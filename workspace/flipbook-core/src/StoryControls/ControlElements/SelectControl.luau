local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState

export type Props = {
	controlSchema: Storyteller.SelectControl,
	controlValue: Storyteller.StoryControlValue,
	onChanged: (nextValue: Storyteller.StoryControlValue) -> (),
}

type ItemId = number | string

local function getItemId(item: unknown): ItemId
	return tostring(item)
end

local function SelectControl(props: Props)
	local activeItemId, setActiveItemId = useState(nil :: ItemId?)

	local itemIdToValue = useMemo(function(): { [ItemId]: Storyteller.StoryControlValue }
		local map = {}
		for _, value in props.controlSchema.items do
			map[getItemId(value)] = value
		end
		return map
	end, { props.controlSchema.items } :: { unknown })

	local items: { Foundation.DropdownItem } = useMemo(function()
		return Sift.List.map(props.controlSchema.items, function(value)
			local id = getItemId(value)
			local isChecked = activeItemId == id

			local item: Foundation.DropdownItem = {
				id = id,
				text = if typeof(props.controlSchema.tostring) == "function"
					then props.controlSchema.tostring(value)
					else tostring(value),
				isChecked = isChecked,
			}

			return item
		end)
	end, { props.controlSchema, activeItemId } :: { unknown })

	local onItemChanged = useCallback(function(itemId)
		setActiveItemId(function(prev)
			return if itemId ~= prev then itemId else nil
		end)

		props.onChanged(itemIdToValue[itemId])
	end, { props.onChanged, itemIdToValue } :: { unknown })

	return e(Foundation.Dropdown.Root, {
		items = items,
		label = "",
		onItemChanged = onItemChanged,
		value = tostring(props.controlValue),
		size = Foundation.Enums.InputSize.Small,
		width = UDim.new(1, 0),
	})
end

return SelectControl
