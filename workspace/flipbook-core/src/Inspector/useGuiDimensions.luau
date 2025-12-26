local React = require("@pkg/React")

local useState = React.useState
local useEffect = React.useEffect

local function useGuiDimensions(gui: GuiObject?): { size: Vector2, position: Vector2 }
	local size, setSize = useState(Vector2.zero)
	local position, setPosition = useState(Vector2.zero)

	useEffect(function(): (() -> ())?
		if gui then
			setSize(gui.AbsoluteSize)
			setPosition(gui.AbsolutePosition)

			local sizeConn = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				setSize(gui.AbsoluteSize)
			end)
			local posConn = gui:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				setPosition(gui.AbsolutePosition)
			end)

			return function()
				sizeConn:Disconnect()
				posConn:Disconnect()
			end
		end
		return nil
	end, { gui })

	return {
		size = size,
		position = position,
	}
end

return useGuiDimensions
