local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Telemetry = require(script.Parent.Parent.Parent["flipbook-telemetry"])

local AppMode = require("@root/Enums/AppMode")
local FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useSignalState = ReactCharm.useSignalState
local useCallback = React.useCallback
local useState = React.useState

local function TelemetryConsentDialog(): React.Node?
	local flipbookStore = FlipbookStoreContext.use()
	local consent = useSignalState(flipbookStore.telemetry.getConsent)
	local isLoading = useSignalState(flipbookStore.telemetry.getIsLoading)
	local isOptedIn, setIsOptedIn = useState(false)
	local isSaving, setIsSaving = useState(false)
	local didSaveFail, setDidSaveFail = useState(false)

	local onClose = useCallback(function()
		if isSaving then
			return
		end

		setIsSaving(true)
		task.spawn(function()
			local decision: Telemetry.ConsentDecision = if isOptedIn
				then Telemetry.ConsentState.Granted
				else Telemetry.ConsentState.Denied
			local saved = flipbookStore.telemetry.setConsent(decision)
			if saved and isOptedIn then
				flipbookStore.telemetry.capture({
					eventName = "TelemetryOptedIn",
				})
			end

			setDidSaveFail(not saved)
			setIsSaving(false)
		end)
	end, { flipbookStore.telemetry, isOptedIn, isSaving } :: { unknown })

	if flipbookStore.story.getMode() == AppMode.EmbeddedClient or isLoading then
		return nil
	end

	if consent ~= Telemetry.ConsentState.Unknown and not didSaveFail then
		return nil
	end

	return React.createElement(Foundation.Dialog.Root, {
		disablePortal = false,
		hasBackdrop = true,
		onClose = onClose,
		onPressedOutside = onClose,
	}, {
		Title = React.createElement(Foundation.Dialog.Title, {
			text = "Help us improve Flipbook",
		}),

		Content = React.createElement(Foundation.Dialog.Content, {
			LayoutOrder = nextLayoutOrder(),
		}, {
			Wrapper = React.createElement(Foundation.View, {
				tag = "auto-xy col gap-large",
			}, {
				MainParagraph = React.createElement(Foundation.Dialog.Text, {
					tag = "auto-xy text-wrap text-body-medium",
					Text = "Flipbook does not send usage data until you choose to share it. Anonymous usage data helps us improve the quality of the plugin.",
					LayoutOrder = nextLayoutOrder(),
				}),

				WhatIsExcluded = React.createElement(Foundation.Dialog.Text, {
					tag = "auto-xy text-wrap text-body-medium",
					Text = "No personal data or story content is collected. You can change this choice at any time in Settings.",
					LayoutOrder = nextLayoutOrder(),
				}),

				Checkbox = React.createElement(Foundation.Checkbox, {
					label = "Help improve Flipbook by sending anonymous usage data",
					isChecked = isOptedIn,
					onActivated = setIsOptedIn,
					LayoutOrder = nextLayoutOrder(),
				}),

				SaveError = if didSaveFail
					then React.createElement(Foundation.Dialog.Text, {
						tag = "auto-xy text-wrap text-body-medium content-alert",
						Text = "Flipbook couldn't save your choice. Try again.",
						LayoutOrder = nextLayoutOrder(),
					})
					else nil,
			}),
		}),

		Actions = React.createElement(Foundation.Dialog.Actions, {
			actions = {
				{
					text = "Done",
					variant = Foundation.Enums.ButtonVariant.Emphasis,
					onActivated = onClose,
				},
			},
			LayoutOrder = nextLayoutOrder(),
		}),
	})
end

return TelemetryConsentDialog
