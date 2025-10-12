local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local SignalsReact = require("@rbxpkg/SignalsReact")

local LocalStorageStore = require("@root/Plugin/LocalStorageStore")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useSignalState = SignalsReact.useSignalState
local useCallback = React.useCallback
local useState = React.useState

local function TelemetryOptOutDialog(): React.Node?
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local localStorageStore = useSignalState(LocalStorageStore.get)
	local storage = useSignalState(localStorageStore.getStorage)
	local isOptedIn = useState(true)

	local onClose = useCallback(function()
		localStorageStore.setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				wasUserPromptedForTelemetry = true,
			})
		end)

		userSettingsStore.setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				collectAnonymousUsageData = isOptedIn,
			})
		end)

		task.spawn(function()
			if isOptedIn then
				fireEventAsync({
					eventName = "TelemetryOptedIn",
				})
			else
				fireEventAsync({
					eventName = "TelemetryOptedOut",
				})
			end
		end)
	end, { localStorageStore.setStorage, userSettingsStore.setStorage, isOptedIn } :: { unknown })

	if storage.wasUserPromptedForTelemetry then
		return nil
	end

	return React.createElement(Foundation.Dialog.Root, {
		disablePortal = false,
		hasBackdrop = true,
		onClose = onClose,
		onPressedOutside = onClose,
	}, {
		Title = React.createElement(Foundation.Dialog.Title, {
			text = "Anonymized telemetry collection",
		}),

		Content = React.createElement(Foundation.Dialog.Content, {
			tag = "col gap-medium",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Body = React.createElement(Foundation.Dialog.Text, {
				tag = "auto-xy text-wrap text-body-medium",
				Text = "Flipbook collects anonymized usage data to like to collect anonymized usage metrics to help improve the quality of the plugin. You can opt out at any time in the settings.",
				LayoutOrder = nextLayoutOrder(),
			}),

			Checkbox = React.createElement(Foundation.Checkbox, {
				label = "Opt-in to telemetry collection",
				isChecked = isOptedIn,
				onActivated = onClose,
				LayoutOrder = nextLayoutOrder(),
			}),
		}),

		Actions = React.createElement(Foundation.Dialog.Actions, {
			actions = {
				{
					text = "Done",
					onActivated = onClose,
				},
			},
			LayoutOrder = nextLayoutOrder(),
		}),
	})
end

return TelemetryOptOutDialog
