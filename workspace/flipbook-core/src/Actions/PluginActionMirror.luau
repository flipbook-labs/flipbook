--[[
	Router 1 — the human door.

	Binds each action to a real PluginAction so it shows up in Studio's shortcuts
	window and can be triggered from a keyboard shortcut. Returns a cleanup
	function that disconnects every `Triggered` connection.

	`CreatePluginAction` errors if the same actionId is created twice in a
	session, so this must run exactly once per plugin load (it does — only at
	bootstrap, and `destroy` tears it down on `Unloading`).

	Shortcut-triggered actions get no payload, so payload-required actions (like
	SelectStory) set `allowBinding = false` and rely on the agent door instead.
]]

local types = require("@root/Actions/types")

local function bindPluginActions(plugin: Plugin, registry: types.ActionRegistry): () -> ()
	local connections: { RBXScriptConnection } = {}

	for _, action in registry.actions do
		local pluginAction = plugin:CreatePluginAction(
			action.id, -- unique actionId (also the save key)
			action.text,
			action.statusTip,
			action.iconName or "",
			action.allowBinding ~= false
		)

		table.insert(
			connections,
			pluginAction.Triggered:Connect(function()
				registry.dispatch(action.id, nil) -- shortcuts can't pass a payload
			end)
		)
	end

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end
end

return bindPluginActions
