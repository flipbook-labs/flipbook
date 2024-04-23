local React = require("@pkg/React")
local themes = require("@root/themes")

local MOCK_STUDIO = {
	ThemeChanged = Instance.new("BindableEvent").Event,
	Theme = {
		Name = "Light",
	},
}

local function useTheme()
	local studio = React.useMemo(function()
		local success, result = pcall(function()
			return (settings() :: any).Studio
		end)

		return if success then result else MOCK_STUDIO
	end, {})

	local theme: themes.Theme, set = React.useState(themes[studio.Theme.Name])

	React.useEffect(function()
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
