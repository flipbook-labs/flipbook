local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local RoactButton = Roact.Component:extend("RoactButton")

function RoactButton:render()
	return Roact.createElement("TextButton", {
		Text = self.props.text,
		[Roact.Event.Activated] = self.props.onActivated,
	})
end

return RoactButton
