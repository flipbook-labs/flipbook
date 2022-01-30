local CoreGui = game:GetService("CoreGui")

local function createViewportPreview(): ScreenGui
	local screen = Instance.new("ScreenGui")
	screen.Name = "StoryPreview"
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	return screen
end

local function useViewportParent(hooks: any): (ScreenGui, boolean, () -> ())
	local viewport = hooks.useValue(createViewportPreview())
	local isUsingViewport, setIsUsingViewport = hooks.useState(false)

	local toggleViewport = hooks.useCallback(function()
		setIsUsingViewport(function(prev)
			return not prev
		end)
	end, { setIsUsingViewport })

	hooks.useEffect(function()
		viewport.value.Parent = if isUsingViewport then CoreGui else nil
	end, { isUsingViewport })

	return viewport.value, isUsingViewport, toggleViewport
end

return useViewportParent
