local types = require(script.Parent.Parent.Parent.types)

export type Node = {
	name: string,
	children: { Node },
	icon: string?,
	instance: Instance?,
	storybook: types.Storybook?,
}

return {}
