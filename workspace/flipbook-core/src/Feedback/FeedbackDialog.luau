local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local DiscardChangesDialog = require("@root/Feedback/DiscardChangesDialog")
local SuccessDialog = require("@root/Feedback/SuccessDialog")
local UsernameConfirmationInput = require("@root/Feedback/UsenameConfirmationInput")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local postFeedbackAsync = require("@root/Feedback/postFeedbackAsync")

local useCallback = React.useCallback
local useEffect = React.useEffect
local useState = React.useState

export type Props = {
	onClose: () -> (),
	LayoutOrder: number?,
}

type IssueType = "bug" | "feature" | "feedback" | "other"

local function FeedbackDialog(props: Props)
	local title, setTitle = useState("" :: string?)
	local body, setBody = useState("" :: string?)
	local isUsernameConfirmed, setIsUsernameConfirmed = useState(false)
	local isDiscardChangesDialogOpen, setIsDiscardChangesDialogOpen = useState(false)
	local isSuccessDialogOpen, setIsSuccessDialogOpen = useState(false)

	local wasChanged = title ~= "" or body ~= "" or isUsernameConfirmed ~= false

	local onCancel = useCallback(function()
		if wasChanged then
			setIsDiscardChangesDialogOpen(true)
		else
			props.onClose()
		end
	end, { wasChanged, props.onClose } :: { unknown })

	local onDiscard = useCallback(function()
		props.onClose()

		task.spawn(function()
			fireEventAsync({
				eventName = "FeedbackDiscarded",
			})
		end)
	end, {})

	local onKeepEditing = useCallback(function()
		setIsDiscardChangesDialogOpen(false)
	end, {})

	local onSubmit = useCallback(function()
		if title ~= "" and body ~= "" and isUsernameConfirmed then
			setIsSuccessDialogOpen(true)

			task.spawn(function()
				postFeedbackAsync(title, body)

				fireEventAsync({
					eventName = "FeedbackSubmitted",
				})
			end)
		end
	end, { title, body, isUsernameConfirmed } :: { unknown })

	useEffect(function()
		task.spawn(function()
			fireEventAsync({
				eventName = "FeedbackDialogOpened",
			})
		end)
	end, {})

	return React.createElement(React.Fragment, nil, {
		FeedbackDialog = if not (isDiscardChangesDialogOpen or isSuccessDialogOpen)
			then React.createElement(Foundation.Dialog.Root, {
				disablePortal = false,
				hasBackdrop = true,
				onClose = props.onClose,
			}, {
				Title = React.createElement(Foundation.Dialog.Title, {
					text = "Send us feedback",
				}),

				Content = React.createElement(Foundation.Dialog.Content, nil, {
					Layout = React.createElement(Foundation.View, {
						tag = "size-full-0 auto-y col gap-medium",
					}, {
						Title = React.createElement(Foundation.TextInput, {
							label = "Title",
							text = title,
							hasError = title == "",
							isRequired = true,
							hint = "Enter a breif summary of the feedback you're giving",
							placeholder = "Enter title...",
							onChanged = setTitle,
							LayoutOrder = nextLayoutOrder(),
						}),

						Body = React.createElement(Foundation.TextInput, {
							label = "Body",
							text = body,
							hasError = body == "",
							isRequired = true,
							hint = "Enter a breif summary of the feedback you're giving",
							placeholder = "Enter body...",
							onChanged = setBody,
							LayoutOrder = nextLayoutOrder(),
						}),

						UsernameConfirmation = React.createElement(UsernameConfirmationInput, {
							onChange = setIsUsernameConfirmed,
							LayoutOrder = nextLayoutOrder(),
						}),
					}),
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

		DiscardChangesDialog = if isDiscardChangesDialogOpen
			then React.createElement(DiscardChangesDialog, {
				onDiscard = onDiscard,
				onKeepEditing = onKeepEditing,
			})
			else nil,

		SuccessDialog = if isSuccessDialogOpen
			then React.createElement(SuccessDialog, {
				onClose = props.onClose,
			})
			else nil,
	})
end

return FeedbackDialog
