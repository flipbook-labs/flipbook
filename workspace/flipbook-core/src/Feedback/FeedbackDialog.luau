local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local UsernameConfirmationInput = require("@root/Feedback/UsenameConfirmationInput")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useState = React.useState
local useCallback = React.useCallback

export type Props = {
	onClose: () -> (),
	LayoutOrder: number?,
}

local function FeedbackDialog(props: Props)
	local summary, setSummary = useState("" :: string?)
	local reproSteps, setReproSteps = useState("" :: string?)
	local errorLogs, setErrorLogs = useState("" :: string?)
	local isCancelDialogOpen, setIsCancelDialogOpen = useState(false)

	local wasChanged = summary ~= "" or reproSteps ~= "" or errorLogs ~= ""

	local onCancel = useCallback(function()
		if wasChanged then
			setIsCancelDialogOpen(true)
		else
			props.onClose()
		end
	end, { wasChanged, props.onClose } :: { unknown })

	local onSubmit = useCallback(function()
		print("submit")

		print(summary)
		print(reproSteps)
		print(errorLogs)

		-- TODO: Send HTTP request to GitHub webhook to create issue
	end, { summary, reproSteps, errorLogs })

	return React.createElement(React.Fragment, nil, {
		FeedbackDialog = if not isCancelDialogOpen
			then React.createElement(Foundation.Dialog.Root, {
				disablePortal = false,
				hasBackdrop = true,
				onClose = props.onClose,
			}, {
				Title = React.createElement(Foundation.Dialog.Title, {
					text = "Report an issue",
				}),

				Summary = React.createElement(Foundation.TextInput, {
					label = "Issue summary",
					text = summary,
					hasError = summary == "",
					isRequired = true,
					hint = "Enter a breif summary of the issue you are encountering",
					placeholder = "Issue summary...",
					onChanged = setSummary,
					LayoutOrder = nextLayoutOrder(),
				}),

				ReproSteps = React.createElement(Foundation.TextInput, {
					label = "Steps to reproduce",
					text = reproSteps,
					hint = "The more details the better. This will help us investigate the issue and resolve it quickly",
					placeholder = "1) Open Plugin 2) Press button 3) Observe error",
					onChanged = setReproSteps,
					LayoutOrder = nextLayoutOrder(),
				}),

				ErrorLogs = React.createElement(Foundation.TextInput, {
					label = "Relevant logs",
					text = errorLogs,
					hint = "Copy any logs from the Output window relevant to the issue",
					placeholder = "Enter logs...",
					onChanged = setErrorLogs,
					LayoutOrder = nextLayoutOrder(),
				}),

				UsernameConfirmation = React.createElement(UsernameConfirmationInput, {
					LayoutOrder = nextLayoutOrder(),
				}),

				Actions = React.createElement(Foundation.Dialog.Actions, {
					actions = {
						{
							variant = Foundation.Enums.ButtonVariant.Standard :: Foundation.ButtonVariant,
							text = "Cancel",
							onActivated = onCancel,
						},
						{
							variant = Foundation.Enums.ButtonVariant.Emphasis,
							text = "Submit",
							onActivated = onSubmit,
						},
					},
					LayoutOrder = nextLayoutOrder(),
				}),
			})
			else nil,

		CancelDialog = if isCancelDialogOpen
			then React.createElement(Foundation.Dialog.Root, {
				disablePortal = false,
				hasBackdrop = true,
			}, {
				Title = React.createElement(Foundation.Dialog.Title, {
					text = "Discard issue report",
				}),

				Message = React.createElement(Foundation.Text, {
					tag = "auto-xy",
					Text = "Are you sure you want to discard your changes?",
					LayoutOrder = nextLayoutOrder(),
				}),

				Actions = React.createElement(Foundation.Dialog.Actions, {
					actions = {
						{
							variant = Foundation.Enums.ButtonVariant.Standard :: Foundation.ButtonVariant,
							text = "Keep editing",
							onActivated = function()
								setIsCancelDialogOpen(false)
							end,
						},
						{
							variant = Foundation.Enums.ButtonVariant.Emphasis,
							text = "Discard",
							onActivated = props.onClose,
						},
					},
					LayoutOrder = nextLayoutOrder(),
				}),
			})
			else nil,
	})
end

return FeedbackDialog
