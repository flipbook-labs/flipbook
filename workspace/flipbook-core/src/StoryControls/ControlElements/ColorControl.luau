local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local e = React.createElement
local useCallback = React.useCallback
local useState = React.useState
local useRef = React.useRef

export type Props = {
	controlSchema: Storyteller.ColorControl,
	controlValue: Color3?,
	onChanged: (nextValue: Color3) -> (),
}

local function ColorControl(props: Props)
	local color, setColor = useState(function()
		return props.controlValue or Color3.new(1, 1, 1)
	end)

	local isColorPickerOpen, setIsColorPickerOpen = useState(false)

	local anchorRef = useRef(nil :: GuiObject?)

	local onColorPreviewActivated = useCallback(function()
		setIsColorPickerOpen(function(prev)
			return not prev
		end)
	end, {})

	local onColorChanged = useCallback(function(newColor: Color3, _brickColor: BrickColor?)
		setColor(newColor)
	end, {})

	local onSubmit = useCallback(function()
		if color then
			props.onChanged(color)
		end
	end, { props.onChanged, color } :: { unknown })

	local onPressedOutside = useCallback(function()
		onSubmit()
		setIsColorPickerOpen(false)
	end, { onSubmit })

	return e(Foundation.View, {
		tag = "auto-xy row gap-small align-y-center",
		stateLayer = {
			affordance = Foundation.Enums.StateLayerAffordance.None,
		},
		onActivated = onColorPreviewActivated,
	}, {
		ColorPreview = e(Foundation.View, {
			tag = "size-500-500 radius-small",
			backgroundStyle = {
				Color3 = color,
				Transparency = 0,
			},
			LayoutOrder = nextLayoutOrder(),
			ref = anchorRef,
		}),

		ColorValue = e(Foundation.Text, {
			tag = "auto-xy content-default text-body-medium",
			Text = `#{color:ToHex():upper()}`,
			LayoutOrder = nextLayoutOrder(),
		}),

		ColorPickerPopover = e(Foundation.Popover.Root, {
			isOpen = isColorPickerOpen,
		}, {
			Anchor = e(Foundation.Popover.Anchor, {
				anchorRef = anchorRef,
			}),

			Content = e(Foundation.Popover.Content, {
				side = Foundation.Enums.PopoverSide.Right,
				align = Foundation.Enums.PopoverAlign.Center,
				onPressedOutside = onPressedOutside,
			}, {
				Wrapper = e(Foundation.View, {
					tag = "auto-xy padding-medium bg-surface-100 radius-small",
					sizeConstraint = {
						MaxSize = Vector2.new(200, 200),
					},
				}, {
					ColorPicker = e(Foundation.ColorPicker, {
						initialColor = color,
						availableModes = {
							"Hex",
							"RGB",
						} :: { any },
						onColorChanged = onColorChanged,
					}),
				}),
			}),
		}),
	})
end

return ColorControl
