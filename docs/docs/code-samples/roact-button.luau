local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Button = Roact.Component:extend("Button")

function Button:render()
	return Roact.createElement("TextButton", {
		Text = self.props.text,
		[Roact.Event.Activated] = self.props.onActivated,
	})
end

return Button
