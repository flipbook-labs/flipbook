local AppMode = require("@root/Enums/AppMode")
local createFlipbookApp = require("@root/createFlipbookApp")
local types = require("@root/Embedding/types")

type LaunchData = types.LaunchData

local function createEmbeddedFlipbookApp(screenGui: ScreenGui, launchData: LaunchData?)
	local app = createFlipbookApp(screenGui, {
		launchData = launchData,
		overlayGui = screenGui :: GuiBase2d,
		mode = AppMode.EmbeddedClient,
	})

	app.mount()

	return app
end

return createEmbeddedFlipbookApp
