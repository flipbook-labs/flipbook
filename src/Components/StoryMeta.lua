local hook = require(script.Parent.Parent.hook)
local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local useTheme = require(script.Parent.Parent.Hooks.useThemeNew)

local Dictionary = Llama.Dictionary
local e = Roact.createElement

type Props = {
	layoutOrder: number,
	story: types.Story,
	storyModule: ModuleScript,
}

local function StoryMeta(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = styles.PADDING,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Title = e(
			"TextLabel",
			Dictionary.join(styles.Header, {
				LayoutOrder = 1,
				Text = props.story.name,
				TextColor3 = theme.text,
			})
		),

		Summary = e(
			"TextLabel",
			Dictionary.join(styles.TextLabel, {
				LayoutOrder = 2,
				Text = props.story.summary,
				TextColor3 = theme.text,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Center,
			}),
			{
				UISizeConstraint = e("UISizeConstraint", {
					MaxSize = Vector2.new(600, math.huge),
				}),
			}
		),
	})
end

return hook(StoryMeta)
