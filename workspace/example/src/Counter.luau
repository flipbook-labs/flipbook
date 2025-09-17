local Roact = require("@pkg/Roact")

local Counter = Roact.Component:extend("Counter")

export type Props = {
	increment: number,
	waitTime: number,
}

export type State = {
	count: number,
}

function Counter:init()
	self:setState({
		count = 0,
	})
end

function Counter:render()
	return Roact.createElement("TextLabel", {
		Text = self.state.count,
		TextScaled = true,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromOffset(300, 100),
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),
	})
end

function Counter:didMount()
	local props: Props = self.props

	self.isMounted = true

	task.spawn(function()
		while self.isMounted do
			self:setState(function(prev: State)
				return {
					count = prev.count + props.increment,
				}
			end)

			task.wait(props.waitTime)
		end
	end)
end

function Counter:willUnmount()
	self.isMounted = false
end

return Counter
