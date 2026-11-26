local Archivist = require("@pkg/Archivist")
local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local formatLogRecord = require("./formatLogRecord")

local useMemo = React.useMemo
local useTokens = Foundation.Hooks.useTokens

local function getLogLevelColor(tokens: Foundation.Tokens, logLevel: Archivist.LogLevel): Color3
	if logLevel == "Warn" then
		return tokens.Color.System.Warning.Color3
	elseif logLevel == "Err" then
		return tokens.Color.System.Alert.Color3
	elseif logLevel == "Info" then
		return tokens.Color.System.Success.Color3
	else
		return tokens.Color.Content.Muted.Color3
	end
end

export type Props = {
	record: Archivist.LogRecord,
}

local function LogLine(props: Props)
	local tokens = useTokens()
	local fontStyle = tokens.Typography.BodyMedium

	local text = useMemo(function()
		return formatLogRecord(props.record, {
			muted = tokens.Color.Content.Muted.Color3,
			level = getLogLevelColor(tokens, props.record.level),
		})
	end, { props.record, tokens } :: { unknown })

	return React.createElement(Foundation.Text, {
		tag = "auto-xy text-wrap text-align-x-left text-align-y-top content-emphasis",
		Text = text,
		RichText = true,
		fontStyle = {
			Font = Enum.Font.RobotoMono,
			FontSize = fontStyle.FontSize,
			LineHeight = fontStyle.LineHeight,
		},
	})
end

return LogLine
