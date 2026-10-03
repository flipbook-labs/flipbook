local GuiService = game:GetService("GuiService")

local React = require("@pkg/React")

local function useTopbarInset(): Rect
	local topbarInset, setTopbarInset = React.useState(GuiService.TopbarInset)

	React.useEffect(function()
		local connection = GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
			setTopbarInset(GuiService.TopbarInset)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return topbarInset
end

return useTopbarInset
