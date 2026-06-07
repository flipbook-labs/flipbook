--[[
	React context that hands the AppController down to the app so it can register
	its concrete capabilities (navigateTo / selectStory / listStories / getState)
	when it mounts. The controller is created at bootstrap, so it may be nil in
	contexts that don't provide one (e.g. stories).
]]

local React = require("@pkg/React")

local types = require("@root/Actions/types")

local Context = React.createContext(nil :: types.AppController?)

local function use(): types.AppController?
	return React.useContext(Context)
end

return {
	Context = Context,
	Provider = Context.Provider,
	use = use,
}
