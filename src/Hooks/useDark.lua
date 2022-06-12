local MOCK_STUDIO = {
	ThemeChanged = Instance.new("BindableEvent").Event,
	Theme = {
		Name = "Light",
	},
}

local function useTheme(hooks: any)
	local studio = hooks.useMemo(function()
		local success, result = pcall(function()
			return (settings() :: any).Studio
		end)

		return if success then result else MOCK_STUDIO
	end, {})

	local isDark: boolean, set = hooks.useState(studio.Theme.Name == "Dark")

	hooks.useEffect(function()
		local conn = studio.ThemeChanged:Connect(function()
			set(studio.Theme.Name == "Dark")
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	return isDark
end

return useTheme
