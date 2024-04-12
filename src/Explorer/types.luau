local flipbook = script:FindFirstAncestor("flipbook")

local storybookTypes = require(flipbook.Storybook.types)
type Storybook = storybookTypes.Storybook

export type ComponentTreeNode = {
	name: string,
	children: { ComponentTreeNode },
	icon: ("folder" | "story" | "storybook")?,
	instance: Instance?,
	storybook: Storybook?,
}

return nil
