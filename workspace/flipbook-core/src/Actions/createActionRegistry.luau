--[[
	Collects the action definitions and centralizes dispatch. This is the single
	choke point both routers (PluginAction mirror + Bindable registry) call, so
	error handling, logging, and result shaping happen in exactly one place.
]]

local definitions = require("@root/Actions/definitions")
local logger = require("@root/logger")
local types = require("@root/Actions/types")

local function createActionRegistry(ctx: types.ActionContext): types.ActionRegistry
	local byId: { [string]: types.Action } = {}
	for _, action in definitions do
		assert(not byId[action.id], `duplicate action id: {action.id}`)
		byId[action.id] = action
	end

	local function dispatch(id: string, payload: any): types.ActionResult
		local action = byId[id]
		if not action then
			return { ok = false, error = `unknown action: {id}` }
		end

		local ok, resultOrErr = pcall(action.run, ctx, payload)
		if not ok then
			logger:Warn(`action {id} failed: {resultOrErr}`)
			return { ok = false, error = tostring(resultOrErr) }
		end

		return { ok = true, result = resultOrErr }
	end

	-- Agent-facing introspection: ids + descriptions + param schema.
	local function manifest(): { types.ManifestEntry }
		local list = {}
		for _, action in definitions do
			table.insert(list, {
				id = action.id,
				text = action.text,
				statusTip = action.statusTip,
				params = action.params,
			})
		end
		return list
	end

	return {
		actions = definitions,
		dispatch = dispatch,
		manifest = manifest,
	}
end

return createActionRegistry
