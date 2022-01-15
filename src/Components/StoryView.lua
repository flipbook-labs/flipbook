local CoreGui = game:GetService("CoreGui")

local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useStory = require(script.Parent.Parent.Hooks.useStory)
local getStoryElement = require(script.Parent.Parent.Modules.getStoryElement)
local enums = require(script.Parent.Parent.enums)
local styles = require(script.Parent.Parent.styles)
local StoryMeta = require(script.Parent.StoryMeta)
local StoryError = require(script.Parent.StoryError)

type Props = {
	story: ModuleScript,
}

local function createViewportPreview(): ScreenGui
	local screen = Instance.new("ScreenGui")
	screen.Name = "StoryPreview"
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	return screen
end

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
	local isUsingViewport, setIsUsingViewport = hooks.useState(false)
	local viewport = hooks.useValue(createViewportPreview())
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

	local onViewportToggled = hooks.useCallback(function()
		setIsUsingViewport(function(prev)
			return not prev
		end)
	end, { setIsUsingViewport })

	local unmount = hooks.useCallback(function()
		if tree.value and prevStory then
			if prevStory.format == enums.Modules.Default then
				prevStory.roact.unmount(tree.value)
			elseif prevStory.format == enums.Modules.Hoarcekat then
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
		viewport.value.Parent = if isUsingViewport then CoreGui else nil
	end, { isUsingViewport })

	hooks.useEffect(function()
		setControls(if story and story.controls then story.controls else {})
	end, { story, setControls })

	hooks.useEffect(function()
		unmount()

		if story then
			local parent = if isUsingViewport then viewport.value else storyParent:getValue()

			if story.format == enums.Modules.Default then
				-- This ensures that the controls are always ready before mounting
				local initialControls = if Llama.isEmpty(controls) then story.controls else controls

				local element = getStoryElement(story, initialControls)

				local success, result = xpcall(function()
					tree.value = story.roact.mount(element, parent, story.name)
				end, debug.traceback)

				if success then
					if err then
						setErr(nil)
					end
				else
					if err ~= result then
						setErr(result)
					end
				end
			elseif story.format == enums.Modules.Hoarcekat then
				local success, result = xpcall(function()
					tree.value = story.story(parent)
				end, debug.traceback)

				if success then
					if err then
						setErr(nil)
					end
				else
					if err ~= result then
						setErr(result)
					end
				end
			end
		end
	end, { story, controls, unmount, storyParent, setErr, isUsingViewport })

	return Roact.createElement("ScrollingFrame", Llama.Dictionary.join(styles.ScrollingFrame, {}), {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Meta = story and Roact.createElement(StoryMeta, {
			layoutOrder = 1,
			story = story,
			storyModule = props.story,
			storyParent = storyParent,
			controls = controls,
			onControlChanged = onControlChanged,
			onViewportToggled = onViewportToggled,
		}),

		Preview = Roact.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			[Roact.Ref] = storyParent,
		}, {
			MountedInViewport = isUsingViewport and Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.TextLabel, {
					Text = "Story mounted in viewport...",
				})
			),

			Error = err and Roact.createElement(StoryError, {
				message = err,
			}),

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = styles.LARGE_PADDING,
				PaddingRight = styles.LARGE_PADDING,
				PaddingBottom = styles.LARGE_PADDING,
				PaddingLeft = styles.LARGE_PADDING,
			}),
		}),
	})
end

return RoactHooks.new(Roact)(StoryView)
