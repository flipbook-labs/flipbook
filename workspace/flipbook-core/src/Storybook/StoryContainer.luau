local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local usePrevious = require("@root/Common/usePrevious")

local render = Storyteller.render
local useCallback = React.useCallback
local useEffect = React.useEffect
local useRef = React.useRef

type LoadedStorybook = Storyteller.LoadedStorybook
type LoadedStory<T> = Storyteller.LoadedStory<T>
type RenderLifecycle = Storyteller.RenderLifecycle

local function StoryContainer(props: {
	story: LoadedStory<unknown>,
	storyProps: { [string]: any }?,
	onError: ((message: string) -> ())?,
})
	local ref = useRef(nil :: Frame?)
	local lifecycle = useRef(nil :: RenderLifecycle?)
	local prevStory = usePrevious(props.story)
	local prevStoryProps = usePrevious(props.storyProps)

	local mount = useCallback(function()
		if lifecycle.current then
			return
		end

		if not ref.current then
			-- logger:Warn("attempted to mount story before ref was ready")
			return
		end

		-- logger:Debug("mounting story")

		local success, result = xpcall(function()
			lifecycle.current = render(ref.current, props.story, props.storyProps)
		end, debug.traceback)

		if not success and props.onError then
			props.onError(result)
		end
	end, { props.story, props.storyProps, props.onError } :: { unknown })

	local update = useCallback(function()
		if not lifecycle.current then
			return
		end

		-- logger:Debug("updating story")

		local success, result = xpcall(function()
			lifecycle.current.update(props.storyProps)
		end, debug.traceback)

		if not success and props.onError then
			props.onError(result)
		end
	end, { props.storyProps, props.onError } :: { unknown })

	local unmount = useCallback(function()
		if not lifecycle.current then
			return
		end

		-- logger:Debug("unmounting story")

		lifecycle.current.unmount()
		lifecycle.current = nil
	end, {})

	-- Main mounting and unmounting logic
	useEffect(function()
		if lifecycle.current then
			if prevStory and props.story ~= prevStory then
				unmount()
			end
		else
			if ref.current and props.story then
				mount()
			end
		end
	end, { props.story, prevStory } :: { unknown })

	-- Unmount when the StoryContainer does
	useEffect(function()
		return unmount
	end, {})

	-- Update when storyProps change
	useEffect(function()
		local didStoryChange = prevStory and props.story == prevStory
		local didStoryPropsChange = prevStoryProps and props.storyProps ~= prevStoryProps

		if lifecycle.current and didStoryChange and didStoryPropsChange then
			update()
		end
	end, { props.story, prevStory, props.storyProps, prevStoryProps, props.onError } :: { unknown })

	return React.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		ref = ref,
	})
end

return StoryContainer
