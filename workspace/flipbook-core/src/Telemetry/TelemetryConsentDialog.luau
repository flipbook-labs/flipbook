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
	local isOptedIn, setIsOptedIn = useState(false)

	local onClose = useCallback(function()
		if isOptedIn then
			flipbookStore.telemetry.setConsent(Telemetry.ConsentState.Granted)
			flipbookStore.telemetry.capture({
				eventName = "TelemetryOptedIn",
			})
		else
			flipbookStore.telemetry.setConsent(Telemetry.ConsentState.Denied)
		end
	end, { flipbookStore.telemetry, isOptedIn } :: { unknown })

	if flipbookStore.story.getMode() == AppMode.EmbeddedClient or consent ~= Telemetry.ConsentState.Unknown then
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
