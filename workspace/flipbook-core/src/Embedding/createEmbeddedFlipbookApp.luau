local AppMode = require("@root/Enums/AppMode")
local createFlipbookApp = require("@root/createFlipbookApp")

export type Options = {
	initialSearchTerm: string?,
}

local function createEmbeddedFlipbookApp(screenGui: ScreenGui, options: Options?)
	local app = createFlipbookApp(screenGui, {
		initialSearchTerm = if options then options.initialSearchTerm else nil,
		overlayGui = screenGui :: GuiBase2d,
		mode = AppMode.EmbeddedClient,
	})

	app.mount()

	return app
end

return createEmbeddedFlipbookApp
