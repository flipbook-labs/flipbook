local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useStory = require(script.Parent.Parent.Hooks.useStory)
local getStoryElement = require(script.Parent.Parent.Modules.getStoryElement)
local styles = require(script.Parent.Parent.styles)
local StoryMeta = require(script.Parent.StoryMeta)

type Props = {
	story: ModuleScript?,
}

local function StoryView(props: Props, hooks: any)
	local storyParent = hooks.useBinding(Roact.createRef())
	local err, setErr = hooks.useState(nil)
	local story, storyErr = useStory(hooks, props.story)

	if storyErr then
		err = storyErr
	end

	hooks.useEffect(function()
		local tree: Dictionary<any>

		if story then
			local element = getStoryElement(story)

			local success, result = pcall(function()
				tree = Roact.mount(element, storyParent:getValue(), story.name)
			end)

			if success then
				setErr(nil)
			else
				setErr(result)
			end
		end

		return function()
			if tree then
				Roact.unmount(tree)
			end
		end
	end, { story, storyParent })

	if not story or err then
		return Roact.createElement(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				Text = if not story then "Select a story to preview it" else err,
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextScaled = true,
				Size = UDim2.fromScale(1, 1),
			})
		)
	else
		return Roact.createElement(
			"ScrollingFrame",
			Llama.Dictionary.join(styles.ScrollingFrame, {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			}),
			{
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Meta = Roact.createElement(StoryMeta, {
					layoutOrder = 1,
					story = story,
				}),

				Preview = Roact.createElement("Frame", {
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 1),
					[Roact.Ref] = storyParent,
				}),
			}
		)
	end
end

return RoactHooks.new(Roact)(StoryView)
