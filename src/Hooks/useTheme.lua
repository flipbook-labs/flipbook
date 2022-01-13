local themes = require(script.Parent.Parent.themes)

local function useTheme(hooks: any)
	local studio = hooks.useMemo(function()
		return settings().Studio
	end, {})

	local theme, set = hooks.useState(themes[studio.Theme.Name])

	hooks.useEffect(function()
		local conn = studio.ThemeChanged:Connect(function()
			set(themes[studio.Theme.Name])
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	return theme
end

return useTheme
