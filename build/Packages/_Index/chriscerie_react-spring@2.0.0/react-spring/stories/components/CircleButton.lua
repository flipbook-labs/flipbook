local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local function Button(props)
	return e("TextButton", {
        AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
		Size = props.Size or UDim2.fromOffset(150, 150),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
        Text = "",

        [React.Event.Activated] = props[React.Event.Activated],
        [React.Event.InputBegan] = props[React.Event.InputBegan],
        [React.Event.InputEnded] = props[React.Event.InputEnded],
	}, {
        UICorner = e("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        UIGradient = e("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 255, 183)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 119, 253)),
            }),
            Rotation = 25,
        }),
    })
end

return Button
