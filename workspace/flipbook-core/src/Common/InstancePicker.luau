local Selection = game:GetService("Selection")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local e = React.createElement
local useCallback = React.useCallback
local useEffect = React.useEffect
local useState = React.useState

export type Props = {
	value: Instance?,
	onChanged: (Instance?) -> (),
	LayoutOrder: number?,
}

local function InstancePicker(props: Props)
	local isSelecting, setIsSelecting = useState(false)
	local isActive, setIsActive = useState(false)

	local onActivated = useCallback(function()
		if isSelecting then
			setIsActive(false)
			setIsSelecting(false)
		else
			setIsSelecting(true)
		end
	end, { isSelecting } :: { unknown })

	local onClear = useCallback(function()
		setIsActive(false)
		setIsSelecting(false)
		props.onChanged(nil)
	end, { props.onChanged } :: { unknown })

	local onStateChanged = useCallback(function(newState: Foundation.ControlState)
		setIsActive(
			newState == Foundation.Enums.ControlState.Hover or newState == Foundation.Enums.ControlState.Pressed
		)
		if newState == Foundation.Enums.ControlState.Disabled then
			setIsSelecting(false)
		end
	end, {})

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

	local buttonIcon = if props.value ~= nil
		then Foundation.Enums.IconName.X
		else Foundation.Enums.IconName.MouseButtonLeft

	return e(Foundation.View, {
		tag = {
			["size-full-1200 row align-y-center gap-small bg-shift-100 radius-medium padding-x-small flex-between stroke-position-inner"] = true,
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
		LayoutOrder = props.LayoutOrder,
	}, {
		Placeholder = if not props.value
			then e(Foundation.Text, {
				tag = "auto-x size-0-full content-muted text-body-small",
				LayoutOrder = 1,
				Text = "Select an Instance...",
			})
			else nil,

		Selection = if props.value
			then e(Foundation.View, {
				tag = "auto-x size-0-full align-y-center col gap-xsmall",
			}, {
				DisplayName = e(Foundation.Text, {
					tag = "auto-xy content-default text-body-small",
					LayoutOrder = 1,
					Text = props.value.Name,
				}),

				FullName = e(Foundation.Text, {
					tag = "auto-xy content-muted text-caption-small",
					LayoutOrder = 2,
					Text = props.value:GetFullName(),
				}),
			})
			else nil,

		PrimaryAction = e(Foundation.IconButton, {
			LayoutOrder = 2,
			icon = buttonIcon,
			size = Foundation.Enums.InputSize.XSmall,
			onActivated = if props.value ~= nil then onClear else onActivated,
		}),
	})
end

return React.memo(InstancePicker)
