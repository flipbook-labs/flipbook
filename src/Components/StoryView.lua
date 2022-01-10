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

local function usePrevious(hooks: any, value: any)
	local prev = hooks.useValue(nil)

	hooks.useEffect(function()
		prev.value = value
	end, { value })

	return prev.value
end

local function StoryView(props: Props, hooks: any)
	local storyParent = Roact.createRef()
	local err, setErr = hooks.useState(nil)
	local story, storyErr = useStory(hooks, props.story)
	local prevStory = usePrevious(hooks, story)
	local controls, setControls = hooks.useState({})
	local prevControls = usePrevious(hooks, controls)
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
		if tree.value and prevStory then
			if prevStory.format == enums.Format.Default then
				prevStory.roact.unmount(tree.value)
			elseif prevStory.format == enums.Format.Hoarcekat then
				local success, result = xpcall(function()
					return tree.value()
				end, debug.traceback)

				if not success then
					setErr(result)
				end
			end

			tree.value = nil
		end
	end, { prevStory, setErr })

	hooks.useEffect(function()
		setControls(if story and story.controls then story.controls else {})
	end, { story, setControls })

	hooks.useEffect(function()
		if not (story and tree.value and controls) then
			return
		end

		if story.format ~= enums.Format.Default then
			return
		end

		if controls ~= prevControls then
			local element = getStoryElement(story, controls)
			story.roact.update(tree.value, element)
		end
	end, { story, controls, prevControls, tree })

	hooks.useEffect(function()
		if story == prevStory then
			return
		end

		unmount()

		if story then
			if story.format == enums.Format.Default then
				local element = getStoryElement(story, controls)

				local success, result = xpcall(function()
					tree.value = story.roact.mount(element, storyParent:getValue(), story.name)
				end, debug.traceback)

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

				setErr(if success then nil else result)

				if success then
					tree.value = result
				end
			end
		end
	end, { story, prevStory, controls, unmount, storyParent, setErr })

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
