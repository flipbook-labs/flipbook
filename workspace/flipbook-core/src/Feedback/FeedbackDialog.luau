local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

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
	local isCancelDialogOpen, setIsCancelDialogOpen = useState(false)
	local isSuccessDialogOpen, setIsSuccessDialogOpen = useState(false)

	local wasChanged = title ~= "" or body ~= "" or isUsernameConfirmed ~= false

	local onCancel = useCallback(function()
		if wasChanged then
			setIsCancelDialogOpen(true)
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
		FeedbackDialog = if not (isCancelDialogOpen or isSuccessDialogOpen)
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

		CancelDialog = if isCancelDialogOpen
			then React.createElement(Foundation.Dialog.Root, {
				disablePortal = false,
				hasBackdrop = true,
			}, {
				Title = React.createElement(Foundation.Dialog.Title, {
					text = "Discard feedback",
				}),

				Content = React.createElement(Foundation.Dialog.Content, nil, {
					Message = React.createElement(Foundation.Text, {
						tag = "auto-xy",
						Text = "Are you sure you want to discard your changes?",
						LayoutOrder = nextLayoutOrder(),
					}),
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
							onActivated = onDiscard,
						},
					},
					LayoutOrder = nextLayoutOrder(),
				}),
			})
			else nil,

		SuccessDialog = if isSuccessDialogOpen
			then React.createElement(Foundation.Dialog.Root, {
				disablePortal = false,
				hasBackdrop = true,
			}, {
				Title = React.createElement(Foundation.Dialog.Title, {
					text = "Feedback posted",
				}),

				Content = React.createElement(Foundation.Dialog.Content, nil, {
					Message = React.createElement(Foundation.Text, {
						tag = "auto-xy",
						Text = "Your feedback has been submitted! Thank you for helping us to improve Flipbook",
						LayoutOrder = nextLayoutOrder(),
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
			else nil,
	})
end

return FeedbackDialog
