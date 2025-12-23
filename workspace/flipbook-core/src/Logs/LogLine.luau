local HttpService = game:GetService("HttpService")

local Foundation = require("@rbxpkg/Foundation")
local Log = require("@pkg/Log")
local React = require("@pkg/React")

local useMemo = React.useMemo
local useTokens = Foundation.Hooks.useTokens

type LogEvent = typeof(Log.LogEvent.new(Log.LogLevel.Information, {}, {}))

local function isLogLevel(str: string)
	local lower = str:lower()
	return lower == "debug" or lower == "warn" or lower == "info" or lower == "err"
end

local function getLogLevelColor(tokens: Foundation.Tokens, logLevel: string): Color3
	local lower = logLevel:lower()
	if lower == "debug" then
		return tokens.Color.Extended.Gray.Gray_600.Color3
	elseif lower == "warn" then
		return tokens.Color.System.Warning.Color3
	elseif lower == "err" then
		return tokens.Color.System.Alert.Color3
	elseif lower == "info" then
		return tokens.Color.System.Success.Color3
	else
		return tokens.Color.Extended.Gray.Gray_600.Color3
	end
end

export type Props = {
	event: LogEvent,
}

local function LogLine(props: Props)
	local tokens = useTokens()
	local fontStyle = tokens.Typography.BodyMedium

	local info = useMemo(function()
		local text = ""

		local timestamp = DateTime.fromUnixTimestamp(props.event.Timestamp)
			:FormatLocalTime("YYYY-MM-DD hh:mm:ss A", "en-us")
		text ..= timestamp

		if #props.event.Prefixes > 0 then
			for _, prefix in props.event.Prefixes do
				if isLogLevel(prefix) then
					local color = getLogLevelColor(tokens, prefix):ToHex()
					text = `{text} <font color="#{color}">{prefix}</font>`
				else
					text = `{text} {prefix}`
				end
			end
		end

		local color = tokens.Color.Extended.Gray.Gray_600.Color3:ToHex()
		text = `<font color="#{color}">{text}</font>`

		return text
	end, { props.event })

	local message = ""
	for _, arg in props.event.Args do
		if typeof(arg) == "table" then
			message ..= HttpService:JSONEncode(arg)
		else
			message ..= tostring(arg)
		end
		message ..= " "
	end

	return React.createElement(Foundation.Text, {
		tag = "auto-xy text-wrap text-align-x-left text-align-y-top content-emphasis",
		Text = `{info}: {message}`,
		RichText = true,
		fontStyle = {
			Font = Enum.Font.RobotoMono,
			FontSize = fontStyle.FontSize,
			LineHeight = fontStyle.LineHeight,
		},
	})
end

return LogLine
