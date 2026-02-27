local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")

local LogLine = require("./LogLine")
local LogsStore = require("./LogsStore")

local useState = React.useState
local useSignalState = ReactCharm.useSignalState

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

	return React.createElement(Foundation.ScrollView, {
		tag = "size-full col gap-xsmall padding-medium",
		scroll = {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.fromScale(1, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		},
	}, children)
end

return LogsView
