local themes = require(script.Parent.Parent.themes)
local types = require(script.Parent.Parent.types)

local function useTheme(hooks: any)
	local theme: types.Theme = hooks.useState(themes.Light)
	return theme
end

return useTheme