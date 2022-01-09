local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useStory = require(script.Parent.Parent.Hooks.useStory)
local getStoryElement = require(script.Parent.Parent.Modules.getStoryElement)
local enums = require(script.Parent.Parent.enums)
local styles = require(script.Parent.Parent.styles)
local StoryMeta = require(script.Parent.StoryMeta)

type Props = {
	story: ModuleScript,
}

local function StoryView(props: Props, hooks: any)
	local storyParent = Roact.createRef()
	local err, setErr = hooks.useState(nil)
	local story, storyErr = useStory(hooks, props.story)
	local controls, setControls = hooks.useState(story and story.controls)
	local tree = hooks.useValue(nil)

	if storyErr then
		err = storyErr
	end

	local onControlChanged = hooks.useCallback(function(key: string, newValue: any)
		setControls(function(prev)
			return Llama.Dictionary.join(prev, {
				[key] = newValue,
			})
		end)
	end, { setControls })

	local unmount = hooks.useCallback(function()
		if tree.value and story then
			if story.format == enums.Format.Default then
				story.roact.unmount(tree.value)
			elseif story.format == enums.Format.Hoarcekat then
				local success, result = xpcall(function()
					return tree.value()
				end, debug.traceback)

				if not success then
					setErr(result)
				end
			end

			tree.value = nil
		end
	end, { story, storyParent })

	hooks.useEffect(function()
		setControls(if story and story.controls then story.controls else {})
	end, { story })

	hooks.useEffect(function()
		unmount()

		if story then
			if story.format == enums.Format.Default then
				local element = getStoryElement(story, controls)

				local success, result = pcall(function()
					tree.value = story.roact.mount(element, storyParent:getValue(), story.name)
				end)

				if success then
					if err then
						setErr(nil)
					end
				else
					setErr(result)
				end
			elseif story.format == enums.Format.Hoarcekat then
				local success, result = xpcall(function()
					return story.story(storyParent:getValue())
				end, debug.traceback)

				if success then
					if err then
						setErr(nil)
					end

					tree.value = result
				else
					setErr(result)
				end
			end
		end

		return unmount
	end, { story, controls, storyParent, setErr })

	if err then
		return Roact.createElement(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				Text = err,
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Size = UDim2.fromScale(1, 1),
			})
		)
	elseif story then
		return Roact.createElement("ScrollingFrame", Llama.Dictionary.join(styles.ScrollingFrame, {}), {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Meta = Roact.createElement(StoryMeta, {
				layoutOrder = 1,
				story = story,
				storyModule = props.story,
				storyParent = storyParent,
				controls = controls,
				onControlChanged = onControlChanged,
			}),

			Preview = Roact.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				[Roact.Ref] = storyParent,
			}),
		})
	end
end

return RoactHooks.new(Roact)(StoryView)
