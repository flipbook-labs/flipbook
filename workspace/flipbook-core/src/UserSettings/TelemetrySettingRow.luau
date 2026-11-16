local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Telemetry = require(script.Parent.Parent.Parent["flipbook-telemetry"])

local AppMode = require("@root/Enums/AppMode")
local FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")

local useCallback = React.useCallback
local useSignalState = ReactCharm.useSignalState

export type Props = {
	layoutOrder: number?,
}

local function TelemetrySettingRow(props: Props): React.Node?
	local flipbookStore = FlipbookStoreContext.use()
	local consent = useSignalState(flipbookStore.telemetry.getConsent)
	local isLoading = useSignalState(flipbookStore.telemetry.getIsLoading)

	local onActivated = useCallback(function(isChecked: boolean)
		task.spawn(function()
			local decision: Telemetry.ConsentDecision = if isChecked
				then Telemetry.ConsentState.Granted
				else Telemetry.ConsentState.Denied
			local saved = flipbookStore.telemetry.setConsent(decision)
			if saved and isChecked then
				flipbookStore.telemetry.capture({
					eventName = "TelemetryOptedIn",
				})
			end
		end)
	end, { flipbookStore.telemetry } :: { unknown })

	if flipbookStore.story.getMode() == AppMode.EmbeddedClient then
		return nil
	end

	return React.createElement(Foundation.View, {
		tag = "size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
	}, {
		OptionWrapper = React.createElement(Foundation.View, {
			tag = "auto-xy padding-x-medium",
		}, {
			Option = React.createElement(Foundation.Checkbox, {
				label = "Help improve Flipbook by sending anonymous usage data",
				hint = "Allow Flipbook to collect anonymous usage data. No personal data or story content is collected.",
				isChecked = consent == Telemetry.ConsentState.Granted,
				isDisabled = isLoading,
				onActivated = onActivated,
			}),
		}),
	})
end

return TelemetrySettingRow
