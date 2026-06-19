--[[
	Public surface of the central Actions registry.

	Behavior is defined once in `definitions/` and routed to the outside world by
	two routers that both converge on `registry.dispatch`:
	  * `bindPluginActions` — human door (Studio shortcuts / menus)
	  * `publishBindables`  — agent door (CoreGui BindableFunctions)
]]

local BindableRegistry = require("@root/Actions/BindableRegistry")
local PluginActionMirror = require("@root/Actions/PluginActionMirror")
local createActionRegistry = require("@root/Actions/createActionRegistry")
local createAppController = require("@root/Actions/createAppController")
local types = require("@root/Actions/types")

export type Action = types.Action
export type ActionContext = types.ActionContext
export type ActionResult = types.ActionResult
export type ActionRegistry = types.ActionRegistry
export type AppController = types.AppController
export type AppControllerImpl = types.AppControllerImpl
export type StoryInfo = types.StoryInfo

return {
	createActionRegistry = createActionRegistry,
	createAppController = createAppController,
	bindPluginActions = PluginActionMirror,
	publishBindables = BindableRegistry,
}
