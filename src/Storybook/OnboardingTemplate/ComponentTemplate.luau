export type Props = {
	nameToGreet: string,
}

local function HelloWorld(props: Props)
	local label = Instance.new("TextLabel")
	label.Text = `Hello, {props.nameToGreet}!`
	label.AutomaticSize = Enum.AutomaticSize.XY
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 24
	label.Font = Enum.Font.BuilderSansMedium

	return label
end

return HelloWorld
