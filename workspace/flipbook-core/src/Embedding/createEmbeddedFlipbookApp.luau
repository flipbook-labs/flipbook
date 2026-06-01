local CommonTypes = require("@root/Common/Types")
local createFlipbookApp = require("@root/createFlipbookApp")

type Pluginlike = CommonTypes.Pluginlike

export type Options = {
	initialStoryPath: string?,
	storyRoot: Instance?,
}

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

local function createEmbeddedFlipbookApp(screenGui: ScreenGui, options: Options?)
	local app = createFlipbookApp(screenGui, {
		initialStoryPath = if options then options.initialStoryPath else nil,
		storyRoot = if options then options.storyRoot else nil,
		plugin = dummyPlugin,
		overlayGui = screenGui :: any,
		viewportGui = screenGui,
		source = "embedded-client",
	})

	app.mount()

	return app
end

return createEmbeddedFlipbookApp
