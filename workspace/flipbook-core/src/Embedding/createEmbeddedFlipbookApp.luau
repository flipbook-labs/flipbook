local AppModeEnum = require("@root/Enums/AppMode")
local createFlipbookApp = require("@root/createFlipbookApp")

local function createEmbeddedFlipbookApp(screenGui: ScreenGui)
	local app = createFlipbookApp(screenGui, {
		overlayGui = screenGui :: GuiBase2d,
		mode = AppModeEnum.EmbeddedClient,
	})

	app.mount()

	return app
end

return createEmbeddedFlipbookApp
