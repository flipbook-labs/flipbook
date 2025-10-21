local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

export type Props = {
	onClose: () -> (),
}

local function SuccessDialog(props: Props)
	return React.createElement(Foundation.Dialog.Root, {
		disablePortal = false,
		hasBackdrop = true,
	}, {
		Title = React.createElement(Foundation.Dialog.Title, {
			text = "Feedback posted",
			LayoutOrder = nextLayoutOrder(),
		}),

		Content = React.createElement(Foundation.Dialog.Content, {
			LayoutOrder = nextLayoutOrder(),
		}, {
			Message = React.createElement(Foundation.Text, {
				tag = "auto-xy text-wrap text-align-x-left text-align-y-top",
				Text = "Your feedback has been submitted! Thank you for helping us to improve Flipbook",
			}),
		}),

		Actions = React.createElement(Foundation.Dialog.Actions, {
			actions = {
				{
					variant = Foundation.Enums.ButtonVariant.Emphasis,
					text = "Close",
					onActivated = props.onClose,
				},
			},
			LayoutOrder = nextLayoutOrder(),
		}),
	})
end

return SuccessDialog
