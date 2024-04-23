local React = require("@pkg/React")

export type Props = {
	increment: number,
	waitTime: number,
}

local function ReactCounter(props: Props)
	local count, setCount = React.useState(0)

	React.useEffect(function()
		local isMounted = true

		task.spawn(function()
			while isMounted do
				setCount(function(prev)
					return prev + props.increment
				end)

				task.wait(props.waitTime)
			end
		end)

		return function()
			isMounted = false
		end
	end, { props })

	return React.createElement("TextLabel", {
		Text = count,
		TextScaled = true,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromOffset(300, 100),
	}, {
		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),
	})
end

return ReactCounter
