local RunService = game:GetService("RunService")

local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local RESIZE_DURATION = 3 -- seconds
local MAX_SIZE = 2000 -- px

local function Story()
	local alpha, setAlpha = React.useState(0)

	React.useEffect(function()
		local conn = RunService.Heartbeat:Connect(function(dt: number)
			setAlpha(function(prev)
				local newAlpha = prev + (dt / RESIZE_DURATION)
				return if newAlpha > 1 then 0 else newAlpha
			end)
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	return React.createElement("TextLabel", {
		Size = UDim2.fromOffset(MAX_SIZE * alpha, MAX_SIZE * alpha),
		AutomaticSize = Enum.AutomaticSize.None,

		TextSize = 24,
		Text = script.Name,
		Font = Enum.Font.GothamBold,
	})
end

return {
	summary = "Resizing test for the story preview",
	react = React,
	reactRoblox = ReactRoblox,
	story = function()
		return React.createElement(Story)
	end,
}
