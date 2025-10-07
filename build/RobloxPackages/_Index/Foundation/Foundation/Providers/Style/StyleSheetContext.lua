local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

-- typeof(Cryo.None) is any, it's a known issue
local context = React.createContext(Cryo.None :: StyleSheet | typeof(Cryo.None))

local function useStyleSheet(): StyleSheet?
	local value = React.useContext(context)
	return if value == Cryo.None then nil else value
end

return {
	Provider = context.Provider,
	useStyleSheet = useStyleSheet,
}
