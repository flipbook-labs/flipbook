local AppMode = require("@root/Enums/AppMode")
local createFlipbookApp = require("@root/createFlipbookApp")
local types = require("@root/Embedding/types")

type LaunchData = types.LaunchData

export type Options = {
	launchData: LaunchData?,
}

local function createEmbeddedFlipbookApp(screenGui: ScreenGui, options: Options?)
	local app = createFlipbookApp(screenGui, {
		launchData = if options then options.launchData else nil,
		overlayGui = screenGui :: GuiBase2d,
		mode = AppMode.EmbeddedClient,
	})

	app.mount()

	return app
end

return createEmbeddedFlipbookApp
