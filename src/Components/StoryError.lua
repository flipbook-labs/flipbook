local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local styles = require(script.Parent.Parent.styles)

type Props = {
	message: string,
}

local function StoryError(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return Roact.createElement(
		"TextLabel",
		Llama.Dictionary.join(styles.TextLabel, {
			Text = props.message,
			Font = Enum.Font.RobotoMono,
			TextWrapped = true,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
		})
	)
end

return RoactHooks.new(Roact)(StoryError)
