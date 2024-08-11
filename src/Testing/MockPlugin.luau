local MockPlugin = {}
MockPlugin.__index = MockPlugin

function MockPlugin.new()
	local self = {
		_settings = {},
	}

	return setmetatable(self, MockPlugin)
end

function MockPlugin:GetSetting(settingName: string)
	return self._settings[settingName]
end

function MockPlugin:SetSetting(settingName: string, newValue: any)
	self._settings[settingName] = newValue
end

function MockPlugin:GetMouse()
	return {
		Icon = "rbxassetid://-1",
	}
end

return MockPlugin
