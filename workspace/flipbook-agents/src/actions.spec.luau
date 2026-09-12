local JestGlobals = require("@pkg/JestGlobals")

local actions = require("@root/actions")

local expect = JestGlobals.expect
local test = JestGlobals.test

local function indexActions()
	local result = {}
	for _, action in actions.create() do
		result[action.name] = action
	end
	return result
end

test("exposes the focused Flipbook action contract", function()
	local names = {}
	for _, action in actions.create() do
		table.insert(names, action.name)
	end

	expect(names).toEqual({
		"openWidget",
		"embedFlipbook",
		"listStorybooks",
		"listStories",
		"openStory",
		"getCurrentStory",
		"getControls",
		"setControls",
	})
end)

test("routes story and control actions through the controller", function()
	local indexed = indexActions()
	local opened = false
	local embeddedParent: string? = nil
	local embeddedOverwrite = false
	local controls: { [string]: unknown } = { text = "Before" }
	local controller = (
		{
			openWidget = function()
				opened = true
			end,
			embedFlipbook = function(parent, overwrite)
				embeddedParent = parent
				embeddedOverwrite = overwrite == true
				return "ReplicatedStorage/Flipbook"
			end,
			listStorybooks = function()
				return { { name = "Example", path = "ReplicatedStorage/Example.storybook" } }
			end,
			listStories = function(storybookPath)
				return { { name = "Button", path = `${storybookPath}/Button.story`, storybook = storybookPath } }
			end,
			openStory = function(storyPath, storybookPath)
				return { name = "Button", path = storyPath, storybook = storybookPath }
			end,
			getCurrentStory = function()
				return { name = "Button", path = "ReplicatedStorage/Button.story", isMounted = true }
			end,
			getControls = function()
				return controls
			end,
			setControls = function(nextControls)
				controls = nextControls
				return controls
			end,
		}
	) :: any

	expect(indexed.openWidget.run(controller, nil)).toEqual({ enabled = true })
	expect(opened).toBe(true)
	expect(indexed.embedFlipbook.run(controller, {
		parent = "ReplicatedStorage",
		overwrite = true,
	})).toEqual({ path = "ReplicatedStorage/Flipbook" })
	expect(embeddedParent).toBe("ReplicatedStorage")
	expect(embeddedOverwrite).toBe(true)
	local storybooks = indexed.listStorybooks.run(controller, nil) :: any
	expect(storybooks.storybooks[1].name).toBe("Example")
	local stories = indexed.listStories.run(controller, { storybook = "ReplicatedStorage/Example.storybook" }) :: any
	expect(stories.stories[1].name).toBe("Button")
	local openedStory = indexed.openStory.run(controller, {
		story = "ReplicatedStorage/Button.story",
		storybook = "ReplicatedStorage/Example.storybook",
	}) :: any
	expect(openedStory.path).toBe("ReplicatedStorage/Button.story")
	local currentStory = indexed.getCurrentStory.run(controller, nil) :: any
	expect(currentStory.isMounted).toBe(true)
	expect(indexed.getControls.run(controller, nil)).toEqual({ controls = { text = "Before" } })
	expect(indexed.setControls.run(controller, { controls = { text = "After" } })).toEqual({
		controls = { text = "After" },
	})
end)
