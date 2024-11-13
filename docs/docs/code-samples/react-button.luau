local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local function Button(props: {
	text: string,
	onActivated: () -> (),
})
	return React.createElement("TextButton", {
		Text = props.text,
		AutomaticSize = Enum.AutomaticSize.XY,
		[React.Event.Activated] = props.onActivated,
	})
end

return Button
