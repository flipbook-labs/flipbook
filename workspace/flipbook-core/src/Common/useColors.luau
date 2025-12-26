local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

type ColorStyle = Foundation.ColorStyle

local useTokens = Foundation.Hooks.useTokens

local useMemo = React.useMemo

local function useColors()
	local tokens = useTokens()

	print(tokens.Config.Theme.Name)

	local colors = useMemo(function()
		return {
			accent = tokens.Color.Extended.Purple.Purple_700,

			github = {
				Color3 = Color3.fromHex("#333333"),
				Transparency = 0,
			},
		}
	end, { tokens })

	return colors
end

return useColors
