local Roact = require(script.Parent.Parent.Packages.Roact)
local storybook = require(script.Parent.Parent["init.storybook"])
local StorybookList = require(script.Parent.StorybookList)

return {
	story = Roact.createElement(StorybookList, {
		storybooks = {
			storybook,
		},
		onStorybookSelected = print,
	}),
}
