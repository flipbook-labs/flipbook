local React = require(script.Parent.Parent.Packages.React)

local function useEvent(event: RBXScriptSignal, callback: (...any) -> ())
	React.useEffect(function()
		local conn = event:Connect(callback)

		return function()
			conn:Disconnect()
		end
	end)
end

return useEvent
