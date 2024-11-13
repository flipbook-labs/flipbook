local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local New = Fusion.New
local OnEvent = Fusion.OnEvent

local function Button(props: {
	text: string,
	onActivated: () -> (),
})
	return New("TextButton")({
		Text = props.text,
		[OnEvent("Activated")] = props.onActivated,
	})
end

return Button
