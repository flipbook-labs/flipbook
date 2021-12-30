local function useTheme(hooks: any)
	local studio = hooks.useMemo(function()
		return settings().Studio
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
