local themes = require(script.Parent.Parent.themes)
local types = require(script.Parent.Parent.types)

local MOCK_STUDIO = {
	ThemeChanged = Instance.new("BindableEvent").Event,
	Theme = {
		Name = "Light",
	},
}

local function useTheme(hooks: any)
	local studio = hooks.useMemo(function()
		local success, result = pcall(function()
			return settings().Studio
		end)

		return if success then result else MOCK_STUDIO
	end, {})

	local theme: types.Theme, set = hooks.useState(themes[studio.Theme.Name])

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
