local Foundation = require("@rbxpkg/Foundation")

type ColorStyle = Foundation.ColorStyle

local useTokens = Foundation.Hooks.useTokens

local function useBrandAccent()
	local tokens = useTokens()
	return tokens.Color.Extended.Purple.Purple_700
end

return useBrandAccent
