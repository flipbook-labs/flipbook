local flipbook = script:FindFirstAncestor("flipbook")
local types = require(flipbook.types)

export type Node = {
	name: string,
	children: { Node },
	icon: string?,
	instance: Instance?,
	storybook: types.Storybook?,
}

return {}
