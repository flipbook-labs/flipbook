local MockPlugin = {}
MockPlugin.__index = MockPlugin

local CommonTypes = require("@root/Common/Types")

type Pluginlike = CommonTypes.Pluginlike

local function simulateDiskAccess()
	task.wait()
	task.wait()
end

function MockPlugin.new(): Pluginlike
	local self = {
		_settings = {},
	}

	return setmetatable(self, MockPlugin) :: any
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

function MockPlugin:OpenScript()
	error("not implemented")
end

return MockPlugin
