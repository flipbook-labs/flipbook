local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local InstancePicker = require("@root/Common/InstancePicker")
local embedIntoExperience = require("@root/Embedding/embedIntoExperience")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local e = React.createElement
local useCallback = React.useCallback
local useState = React.useState

export type Props = {
	onClose: () -> (),
}

local function EmbedIntoExperienceDialog(props: Props)
	local selectedDestination, setSelectedDestination = useState(ReplicatedStorage :: Instance?)
	local statusMessage, setStatusMessage = useState(nil :: string?)

	local onEmbed = useCallback(function()
		local success, result = pcall(function()
			return embedIntoExperience(selectedDestination)
		end)

		if success then
			setStatusMessage(`Embedded Flipbook into {(result :: Instance):GetFullName()}.`)
		else
			setStatusMessage(`Failed to embed Flipbook: {result}`)
		end
	end, { selectedDestination })

	return e(Foundation.Dialog.Root, {
		disablePortal = false,
		hasBackdrop = true,
		onClose = props.onClose,
		onPressedOutside = props.onClose,
	}, {
		Title = e(Foundation.Dialog.Title, {
			text = "Embed Flipbook into Experience",
		}),

		Content = e(Foundation.Dialog.Content, {
			LayoutOrder = nextLayoutOrder(),
		}, {
			Wrapper = e(Foundation.View, {
				tag = "auto-xy col gap-large",
			}, {
				Description = e(Foundation.Dialog.Text, {
					LayoutOrder = nextLayoutOrder(),
					tag = "auto-xy text-wrap text-body-medium",
					Text = "Flipbook will clone its runtime into the experience. Select a destination from the Explorer to control where it gets parented.",
				}),

				Destination = e(Foundation.View, {
					LayoutOrder = nextLayoutOrder(),
					tag = "auto-y size-full-0",
				}, {
					InstancePicker = e(InstancePicker, {
						value = selectedDestination,
						onChanged = setSelectedDestination,
					}),
				}),

				Status = if statusMessage ~= nil
					then e(Foundation.Dialog.Text, {
						LayoutOrder = nextLayoutOrder(),
						tag = "auto-xy text-wrap text-body-medium",
						Text = statusMessage,
					})
					else nil,
			}),
		}),

		Actions = e(Foundation.Dialog.Actions, {
			LayoutOrder = nextLayoutOrder(),
			actions = {
				{
					text = "Cancel",
					onActivated = props.onClose,
				},
				{
					text = "Embed",
					variant = Foundation.Enums.ButtonVariant.Emphasis,
					isDisabled = selectedDestination == nil,
					onActivated = onEmbed,
				},
			},
		}),
	})
end

return EmbedIntoExperienceDialog
