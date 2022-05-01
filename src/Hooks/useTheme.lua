local MOCK_STUDIO = {
	ThemeChanged = Instance.new("BindableEvent").Event,
	Theme = {
		GetColor = function() end,
	},
}

local function useTheme(hooks: any)
	local studio = hooks.useMemo(function()
		local success, result = pcall(function()
			return (settings() :: any).Studio
		end)

		return if success then result else MOCK_STUDIO
	end, {})

	local theme: StudioTheme, set = hooks.useState(studio.Theme)

	hooks.useEffect(function()
		local conn = studio.ThemeChanged:Connect(function()
			set(studio.Theme)
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	return theme
end

return useTheme
