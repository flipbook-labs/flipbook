local Roact = require(script.Parent.Parent.Packages.Roact)
local StoryError = require(script.Parent.StoryError)

return {
	summary = "Displays the error message when something goes wrong in a story",
	story = Roact.createElement(StoryError, {
		message = [[
14:27:55.439  PluginDebugService.user_flipbook.rbxm.flipbook.Components.App:11: oops  -  Edit - App:11
14:27:55.439  Stack Begin  -  Studio
14:27:55.439  Script 'PluginDebugService.user_flipbook.rbxm.flipbook.Components.App', Line 11  -  Studio - App:11
14:27:55.439  Stack End  -  Studio
]],
	}),
}
