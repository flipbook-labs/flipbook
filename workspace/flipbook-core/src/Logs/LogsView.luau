local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")

local LogLine = require("./LogLine")
local LogsStore = require("./LogsStore")

local useState = React.useState
local useSignalState = SignalsReact.useSignalState

local function LogsView()
	local logsStore = useSignalState(LogsStore.get)
	local history = useSignalState(logsStore.getHistory)

	local maxLines, _setMaxLine = useState(100)

	local children: { [string]: React.Node } = {}
	for i = math.min(#history, maxLines), 1, -1 do
		children[`Line{i}`] = React.createElement(LogLine, {
			event = history[i],
		})
	end

	return React.createElement(Foundation.View, {
		tag = "size-full-0 auto-y col gap-xsmall padding-medium",
	}, children)
end

return LogsView
