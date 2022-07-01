local flipbook = script:FindFirstAncestor("flipbook")

local types = require(script.Parent.Parent.types)

export type Node = {
	name: string,
	children: { Node },
	icon: string?,
	instance: Instance?,
	storybook: types.Storybook?,
}

return {}
