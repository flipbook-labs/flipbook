local Storyteller = require("@pkg/Storyteller")

type LoadedStorybook = Storyteller.LoadedStorybook

export type ComponentTreeNode = {
	name: string,
	children: { ComponentTreeNode },
	icon: ("folder" | "story" | "storybook")?,
	instance: Instance?,
	storybook: LoadedStorybook?,
}

return nil
