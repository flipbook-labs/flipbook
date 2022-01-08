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
	local controls, setControls = hooks.useState(story and story.controls)
	local tree = hooks.useValue(nil)

	if storyErr then
		err = storyErr
	end

	local onControlChanged = hooks.useCallback(function(key: string, newValue: any)
		setControls(Llama.Dictionary.join(controls, {
			[key] = newValue,
		}))
	end, { controls, setControls })

	hooks.useEffect(function()
		if story and story.controls then
			setControls(story.controls)
		end
	end, { story })

	local unmount = hooks.useCallback(function()
		if tree.value then
			Roact.unmount(tree.value)
			tree.value = nil
		end
	end, {})

	hooks.useEffect(function()
		unmount()

		if story then
			local element = getStoryElement(story, controls)

			local success, result = pcall(function()
				tree.value = Roact.mount(element, storyParent:getValue(), story.name)
			end)

			if success then
				setErr(nil)
			else
				setErr(result)
			end
		end

		return unmount
	end, { story, controls, storyParent })

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
					controls = controls,
					onControlChanged = onControlChanged,
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
