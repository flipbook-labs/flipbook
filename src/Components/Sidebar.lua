local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local StorybookList = require(script.Parent.StorybookList)
local StoryList = require(script.Parent.StoryList)

type Props = {
	storybooks: ({ types.Storybook }?),
	stories: ({ types.Story }?),
	selectStory: (types.Story) -> nil,
	selectStorybook: (types.Storybook) -> nil,
}

local function Sidebar(props: Props, hooks: any)
	local theme = useTheme(hooks)

	local children = {}

	children.SizeConstraint = Roact.createElement("UISizeConstraint", {
		MaxSize = props.maxSize,
	})

	if props.storybooks then
		children.Storybooks = Roact.createElement(StorybookList, {
			storybooks = props.storybooks,
			onStorybookSelected = props.selectStorybook,
		})
	elseif props.stories then
		children.Stories = Roact.createElement(StoryList, {
			stories = props.stories,
			onStorySelected = props.selectStory,
		})
	end

	return Roact.createElement(
		"ScrollingFrame",
		Llama.Dictionary.join(styles.ScrollingFrame, {
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		}),
		children
	)
end

return RoactHooks.new(Roact)(Sidebar)
