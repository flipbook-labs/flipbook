local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

export type Props = {
	onKeepEditing: () -> (),
	onDiscard: () -> (),
}

local function DiscardChangesDialog(props: Props)
	return React.createElement(Foundation.Dialog.Root, {
		disablePortal = false,
		hasBackdrop = true,
	}, {
		Title = React.createElement(Foundation.Dialog.Title, {
			text = "Discard feedback",
		}),

		Content = React.createElement(Foundation.Dialog.Content, nil, {
			Message = React.createElement(Foundation.Text, {
				tag = "auto-xy padding-top-medium",
				Text = "Are you sure you want to discard your changes?",
				LayoutOrder = nextLayoutOrder(),
			}),
		}),

		Actions = React.createElement(Foundation.Dialog.Actions, {
			actions = {
				{
					variant = Foundation.Enums.ButtonVariant.Standard :: Foundation.ButtonVariant,
					text = "Keep editing",
					onActivated = props.onKeepEditing,
				},
				{
					variant = Foundation.Enums.ButtonVariant.Emphasis,
					text = "Discard",
					onActivated = props.onDiscard,
				},
			},
			LayoutOrder = nextLayoutOrder(),
		}),
	})
end

return DiscardChangesDialog
