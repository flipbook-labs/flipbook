local HttpService = game:GetService("HttpService")

local Archivist = require("@pkg/Archivist")
local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

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

local function stringify(value: unknown): string
	if typeof(value) == "table" then
		local ok, encoded = pcall(HttpService.JSONEncode, HttpService, value)
		if ok then
			return encoded
		end
	end
	return tostring(value)
end

export type Props = {
	record: Archivist.LogRecord,
}

local function LogLine(props: Props)
	local tokens = useTokens()
	local fontStyle = tokens.Typography.BodyMedium

	local text = useMemo(function()
		local mutedColor = tokens.Color.Content.Muted.Color3:ToHex()
		local levelColor = getLogLevelColor(tokens, props.record.level):ToHex()

		local timestamp = DateTime.fromUnixTimestamp(props.record.timestamp)
			:FormatLocalTime("YYYY-MM-DD hh:mm:ss A", "en-us")
		local info = `{timestamp} <font color="#{levelColor}">{props.record.level:lower()}</font> {props.record.name}`

		local parts = {}
		for index = 1, props.record.args.n do
			table.insert(parts, stringify(props.record.args[index]))
		end
		if props.record.fields then
			table.insert(parts, stringify(props.record.fields))
		end

		return `<font color="#{mutedColor}">{info}</font>: {table.concat(parts, " ")}`
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
