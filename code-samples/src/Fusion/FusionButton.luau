local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local New = Fusion.New
local OnEvent = Fusion.OnEvent

local function FusionButton(props: {
	text: string,
	onActivated: () -> (),
})
	return New("TextButton")({
		Text = props.text,
		[OnEvent("Activated")] = props.onActivated,
	})
end

return FusionButton
