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

	local onActivated = useCallback(function(isChecked: boolean)
		if isChecked then
			flipbookStore.telemetry.setConsent(Telemetry.ConsentState.Granted)
			flipbookStore.telemetry.capture({
				eventName = "TelemetryOptedIn",
			})
		else
			flipbookStore.telemetry.setConsent(Telemetry.ConsentState.Denied)
		end
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
				onActivated = onActivated,
			}),
		}),
	})
end

return TelemetrySettingRow
