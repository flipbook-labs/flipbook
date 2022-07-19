local ZOOM_INCREMENT = 0.25

local function useZoom(hooks: any, story: ModuleScript)
	local value, setValue = hooks.useState(0)

	local zoomIn = hooks.useCallback(function()
		setValue(value + ZOOM_INCREMENT)
	end, { value, setValue })

	local zoomOut = hooks.useCallback(function()
		setValue(value - ZOOM_INCREMENT)
	end, { value, setValue })

	hooks.useEffect(function()
		setValue(0)
	end, { story })

	return {
		value = value,
		zoomIn = zoomIn,
		zoomOut = zoomOut,
	}
end

return useZoom
