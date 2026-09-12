local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local createTreeNodesForStorybook = require("./createTreeNodesForStorybook")

local expect = JestGlobals.expect
local test = JestGlobals.test

type LoadedStory = Storyteller.LoadedStory<unknown>
type LoadedStorybook = Storyteller.LoadedStorybook

test("reads records grouped by storybook source and story module", function()
	local storyRoot = Instance.new("Folder")
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = "Button.story"
	storyModule.Parent = storyRoot

	local storybookSource = Instance.new("ModuleScript")
	local storybook: LoadedStorybook = {
		name = "Storybook",
		source = storybookSource,
		storyRoots = { storyRoot :: Instance },
	}
	local function makeStory(id: string, name: string): LoadedStory
		return {
			id = id,
			name = name,
			story = function()
				return nil
			end,
			source = storyModule,
			storybook = storybook,
		}
	end

	local root = createTreeNodesForStorybook(storybook, {
		[storybookSource] = {
			[storyModule] = {
				name = "Buttons",
				stories = {
					makeStory("primary", "Primary"),
					makeStory("secondary", "Secondary"),
				},
			},
		},
	})
	local group = root.getChildren()[1]

	expect(group.getName()).toBe("Buttons")
	expect(group.getChildren()[1].getStoryId()).toBe("primary")
	expect(group.getChildren()[2].getStoryId()).toBe("secondary")
end)
