local Storyteller = require("@pkg/Storyteller")

type Storybook = Storyteller.Storybook

export type ComponentTreeNode = {
	name: string,
	children: { ComponentTreeNode },
	icon: ("folder" | "story" | "storybook")?,
	instance: Instance?,
	storybook: Storybook?,
}

return nil
