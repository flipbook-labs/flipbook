local MockPlugin = {}
MockPlugin.__index = MockPlugin

local function simulateDiskAccess()
	task.wait()
	task.wait()
end

function MockPlugin.new(): Plugin
	local self = {
		_settings = {},
		_pluginActions = {},
	}

	return setmetatable(self, MockPlugin) :: any
end

-- Mirrors plugin:CreatePluginAction. Returns a fake PluginAction whose
-- `Triggered` is backed by a BindableEvent so tests can simulate a trigger via
-- `action.trigger()`. Created actions are retrievable with `getPluginAction`.
function MockPlugin:CreatePluginAction(
	actionId: string,
	text: string,
	statusTip: string,
	iconName: string?,
	allowBinding: boolean?
)
	local bindable = Instance.new("BindableEvent")
	local action = {
		ActionId = actionId,
		Text = text,
		StatusTip = statusTip,
		IconName = iconName,
		AllowBinding = allowBinding,
		Triggered = bindable.Event,
		trigger = function()
			bindable:Fire()
		end,
	}
	self._pluginActions[actionId] = action
	return action
end

function MockPlugin:getPluginAction(actionId: string)
	return self._pluginActions[actionId]
end

function MockPlugin:GetSetting(settingName: string)
	simulateDiskAccess()
	return self._settings[settingName]
end

function MockPlugin:SetSetting(settingName: string, newValue: any)
	simulateDiskAccess()
	self._settings[settingName] = newValue
end

function MockPlugin:GetMouse()
	return {
		Icon = "rbxassetid://-1",
	}
end

return MockPlugin
