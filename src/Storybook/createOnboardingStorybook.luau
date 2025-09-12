local STORYBOOK_TEMPLATE = script.Parent.OnboardingTemplate["StorybookTemplate"]
local STORY_TEMPLATE = script.Parent.OnboardingTemplate["StoryTemplate"]
local COMPONENT_TEMPLATE = script.Parent.OnboardingTemplate["ComponentTemplate"]

local function createOnboardingStorybook(storybookName: string, parent: Instance)
	local components = parent:FindFirstChild("Components")
	if not components then
		components = Instance.new("Folder")
		components.Name = "Components"
	end

	local component = COMPONENT_TEMPLATE:Clone()
	component.Name = "HelloWorld"
	component.Parent = components

	local story = STORY_TEMPLATE:Clone()
	story.Name = "HelloWorld.story"
	story.Parent = components

	local storybookModule = STORYBOOK_TEMPLATE:Clone()
	storybookModule.Name = `{storybookName}.storybook`

	components.Parent = parent
	storybookModule.Parent = parent
end

return createOnboardingStorybook
