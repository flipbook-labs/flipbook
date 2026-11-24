local React = require("@pkg/React")

local function useEvent(event: RBXScriptSignal, callback: (...unknown) -> ())
	React.useEffect(function()
		local conn = event:Connect(callback)

		return function()
			conn:Disconnect()
		end
	end)
end

return useEvent
