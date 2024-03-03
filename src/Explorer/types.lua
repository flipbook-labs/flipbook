local storybookTypes = require("@root/Storybook/types")

type Storybook = storybookTypes.Storybook

export type ComponentTreeNode = {
	name: string,
	children: { ComponentTreeNode },
	icon: string?,
	instance: Instance?,
	storybook: Storybook?,
}

return nil
