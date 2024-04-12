local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)

local function useEvent(event: RBXScriptSignal, callback: (...any) -> ())
	React.useEffect(function()
		local conn = event:Connect(callback)

		return function()
			conn:Disconnect()
		end
	end)
end

return useEvent
