local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local logger = require("@root/logger")
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
	extraProps: { [string]: any }?,
	onError: ((message: string) -> ())?,
})
	local ref = useRef(nil :: Frame?)
	local lifecycle = useRef(nil :: RenderLifecycle?)
	local prevStory = usePrevious(props.story)
	local prevExtraProps = usePrevious(props.extraProps)

	local mount = useCallback(function()
		if lifecycle.current then
			return
		end

		if not ref.current then
			logger:Warn("attempted to mount story before ref was ready")
			return
		end

		logger:Debug("mounting story")

		local success, result = xpcall(function()
			lifecycle.current = render(ref.current, props.story, props.extraProps)
		end, debug.traceback)

		if not success and props.onError then
			props.onError(result)
		end
	end, { props.story, props.extraProps, props.onError } :: { unknown })

	local update = useCallback(function()
		if not lifecycle.current then
			return
		end

		logger:Debug("updating story")

		local success, result = xpcall(function()
			lifecycle.current.update(props.extraProps)
		end, debug.traceback)

		if not success and props.onError then
			props.onError(result)
		end
	end, { props.extraProps, props.onError } :: { unknown })

	local unmount = useCallback(function()
		if not lifecycle.current then
			return
		end

		logger:Debug("unmounting story")

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

	-- Update when extraProps change
	useEffect(function()
		local didStoryChange = prevStory and props.story == prevStory
		local didExtraPropsChange = prevExtraProps and props.extraProps ~= prevExtraProps

		if lifecycle.current and didStoryChange and didExtraPropsChange then
			update()
		end
	end, { props.story, prevStory, props.extraProps, prevExtraProps, props.onError } :: { unknown })

	return React.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		ref = ref,
	})
end

return StoryContainer
