local CommonTypes = require("@root/Common/Types")
local createFlipbookApp = require("@root/createFlipbookApp")

type Pluginlike = CommonTypes.Pluginlike

local dummyPlugin: Pluginlike = {
	GetMouse = function()
		return {
			Icon = "",
		} :: any
	end,
	GetSetting = function()
		return nil
	end,
	OpenScript = function() end,
	SetSetting = function() end,
}

local function createEmbeddedFlipbookApp(screenGui: ScreenGui)
	local app = createFlipbookApp(screenGui, {
		plugin = dummyPlugin,
		overlayGui = screenGui :: any,
		viewportGui = screenGui,
	})

	app.mount()

	return app
end

return createEmbeddedFlipbookApp
