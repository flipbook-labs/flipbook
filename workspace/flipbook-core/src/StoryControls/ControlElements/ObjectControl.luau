local Selection = game:GetService("Selection")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback
local useEffect = React.useEffect
local useState = React.useState

export type Props = {
	controlSchema: Storyteller.ObjectControl,
	controlValue: Instance?,
	onChanged: (Instance?) -> (),
}

local PLACEHOLDER = "Select an Instance"

local function ObjectControl(props: Props)
	local isSelecting, setIsSelecting = useState(false)
	local isActive, setIsActive = useState(false)

	local currentValue = props.controlValue or props.controlSchema.default

	local onActivated = useCallback(function()
		-- When selected, this will deselect the input giving the user an escape
		-- route.
		if isSelecting then
			setIsActive(false)
			setIsSelecting(false)
			return
		end

		if currentValue ~= nil then
			props.onChanged(nil)
		else
			setIsSelecting(true)
		end
	end, { currentValue, isSelecting, props.onChanged } :: { unknown })

	local onStateChanged = useCallback(function(newState: Foundation.ControlState)
		setIsActive(
			newState == Foundation.Enums.ControlState.Hover or newState == Foundation.Enums.ControlState.Pressed
		)
		if newState == Foundation.Enums.ControlState.Disabled then
			setIsSelecting(false)
		end
	end, {})

	-- TODO: Don't clear the selection when picking again. Allow the user to
	-- press Esc to deselect or click the selected instance again to deselect.

	useEffect(function()
		if not isSelecting then
			return
		end

		local connection = Selection.SelectionChanged:Connect(function()
			local selected = Selection:Get()
			if selected[1] ~= nil then
				props.onChanged(selected[1])
				setIsSelecting(false)
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, { isSelecting, props.onChanged } :: { unknown })

	local buttonIcon = if currentValue ~= nil
		then Foundation.Enums.IconName.X
		else Foundation.Enums.IconName.MouseButtonLeft

	local root: React.ReactElement<any> = e(Foundation.View, {
		tag = {
			["size-full-800 row align-y-center gap-small bg-shift-100 radius-medium padding-x-small flex-between stroke-position-inner"] = true,
			["stroke-standard"] = not isActive,
			["stroke-thick"] = isActive or isSelecting,
			["stroke-default"] = not isSelecting,
			["stroke-system-emphasis"] = isSelecting,
		},
		onStateChanged = onStateChanged,
		stateLayer = {
			affordance = Foundation.Enums.StateLayerAffordance.None,
		},
		onActivated = onActivated,
	}, {
		Placeholder = if not currentValue
			then e(Foundation.Text, {
				tag = "auto-x size-0-full content-muted text-body-medium",
				LayoutOrder = 1,
				Text = if currentValue then currentValue.Name else PLACEHOLDER,
			})
			else nil,

		Selection = if currentValue
			then e(Foundation.View, {
				tag = "auto-xy col",
			}, {
				DisplayName = e(Foundation.Text, {
					tag = "auto-xy content-default text-body-medium",
					LayoutOrder = 1,
					Text = currentValue.Name,
				}),

				FullName = e(Foundation.Text, {
					tag = "auto-xy content-muted text-body-small",
					LayoutOrder = 2,
					Text = currentValue:GetFullName(),
				}),
			})
			else nil,

		PrimaryAction = e(Foundation.IconButton, {
			LayoutOrder = 2,
			icon = buttonIcon,
			size = Foundation.Enums.InputSize.XSmall,
			onActivated = onActivated,
		}),
	})

	return root
end

return React.memo(ObjectControl)
