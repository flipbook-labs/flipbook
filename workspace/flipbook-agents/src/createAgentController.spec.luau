local JestGlobals = require("@pkg/JestGlobals")

local StoryStatus = require("@root/StoryStatus")
local createAgentController = require("@root/createAgentController")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local function createScreen(): LayerCollector
	local screen = Instance.new("ScreenGui")
	screen.Enabled = false
	return screen
end

local function createStoryAdapter(path: string, initialValue: string, id: string?)
	local controls: { [string]: unknown } = { label = initialValue }
	return {
		id = id or "default",
		path = path,
		getControls = function()
			return controls
		end,
		setControls = function(nextControls)
			for key, value in nextControls do
				controls[key] = value
			end
			return controls
		end,
	}
end

describe("app registration", function()
	test("opens an embedded screen surface", function()
		local screenGui = createScreen()
		screenGui.Enabled = false
		local controller = createAgentController(screenGui)

		controller.openWidget()

		expect(screenGui.Enabled).toBe(true)
	end)

	test("routes app actions through the current adapter", function()
		local screen = createScreen()
		local controller = createAgentController(screen)
		local cleanup = controller.registerApp({
			embedFlipbook = function(parentPath, overwrite)
				expect(parentPath).toBe("ReplicatedStorage")
				expect(overwrite).toBe(true)
				return "ReplicatedStorage/Flipbook"
			end,
			listStorybooks = function()
				return {
					{ name = "Example", path = "ReplicatedStorage/Example.storybook" },
				}
			end,
			listStories = function(storybookPath)
				if storybookPath == nil then
					return {
						{
							id = "default",
							status = StoryStatus.Loaded,
							name = "Orphan",
							path = "ReplicatedStorage/Orphan.story",
						},
					}
				end
				return {
					{
						id = "default",
						status = StoryStatus.Loaded,
						name = "Button",
						path = `${storybookPath}/Button.story`,
						storybook = storybookPath,
					},
				}
			end,
			openStory = function(storyPath, storybookPath, storyId)
				return {
					id = storyId or "default",
					status = StoryStatus.Loaded,
					name = "Button",
					path = storyPath,
					storybook = storybookPath,
				}
			end,
			getCurrentStory = function()
				return nil
			end,
		})

		expect(controller.listStorybooks()[1].name).toBe("Example")
		expect(controller.embedFlipbook("ReplicatedStorage", true)).toBe("ReplicatedStorage/Flipbook")
		expect(controller.listStories("ReplicatedStorage/Example.storybook")[1].name).toBe("Button")
		expect(controller.listStories(nil)[1].name).toBe("Orphan")
		expect(controller.openStory("ReplicatedStorage/Button.story", nil).path).toBe("ReplicatedStorage/Button.story")
		expect(controller.openStory("ReplicatedStorage/Button.story", nil, "secondary").id).toBe("secondary")
		expect(screen.Enabled).toBe(true)

		cleanup()
		expect(function()
			controller.listStorybooks()
		end).toThrow("Flipbook app is not mounted")
	end)
end)

describe("story registration", function()
	test("reports readiness and updates controls through the mounted story", function()
		local controller = createAgentController(createScreen())
		local currentStoryPath = "ReplicatedStorage/Button.story"
		controller.registerApp({
			embedFlipbook = function()
				return "ReplicatedStorage/Flipbook"
			end,
			listStorybooks = function()
				return {}
			end,
			listStories = function()
				return {}
			end,
			openStory = function()
				return {
					id = "default",
					status = StoryStatus.Loaded,
					name = "Button",
					path = "ReplicatedStorage/Button.story",
				}
			end,
			getCurrentStory = function()
				return {
					id = "default",
					status = StoryStatus.Loaded,
					name = "Button",
					path = currentStoryPath,
				}
			end,
		})

		expect(controller.getCurrentStory()).toEqual({
			id = "default",
			status = StoryStatus.Loaded,
			name = "Button",
			path = "ReplicatedStorage/Button.story",
			isMounted = false,
		})
		expect(controller.getControls()).toEqual({})

		local cleanup = controller.registerStory(createStoryAdapter("ReplicatedStorage/Button.story", "Before"))
		local mountedStory = controller.getCurrentStory()
		assert(mountedStory ~= nil, "expected a current story")
		expect(mountedStory.isMounted).toBe(true)
		expect(controller.setControls({ label = "After" })).toEqual({ label = "After" })

		currentStoryPath = "ReplicatedStorage/Other.story"
		expect(controller.getControls()).toEqual({})
		expect(function()
			controller.setControls({ label = "Wrong story" })
		end).toThrow("setControls requires the story view to be mounted")

		cleanup()
		local unmountedStory = controller.getCurrentStory()
		assert(unmountedStory ~= nil, "expected a current story")
		expect(unmountedStory.isMounted).toBe(false)
		expect(function()
			controller.setControls({ label = "Again" })
		end).toThrow("setControls requires the story view to be mounted")
	end)

	test("treats another Story from the same module as unmounted", function()
		local controller = createAgentController(createScreen())
		local currentStoryId = "primary"
		controller.registerApp({
			embedFlipbook = function()
				return "ReplicatedStorage/Flipbook"
			end,
			listStorybooks = function()
				return {}
			end,
			listStories = function()
				return {}
			end,
			openStory = function()
				error("not used")
			end,
			getCurrentStory = function()
				return {
					id = currentStoryId,
					status = StoryStatus.Loaded,
					name = currentStoryId,
					path = "ReplicatedStorage/Buttons.story",
				}
			end,
		})
		controller.registerStory(createStoryAdapter("ReplicatedStorage/Buttons.story", "Primary", "primary"))

		local primary = controller.getCurrentStory()
		assert(primary ~= nil, "expected a current story")
		expect(primary.isMounted).toBe(true)
		expect(controller.getControls()).toEqual({ label = "Primary" })

		currentStoryId = "secondary"
		local secondary = controller.getCurrentStory()
		assert(secondary ~= nil, "expected a current story")
		expect(secondary.id).toBe("secondary")
		expect(secondary.isMounted).toBe(false)
		expect(controller.getControls()).toEqual({})
		expect(function()
			controller.setControls({ label = "Wrong story" })
		end).toThrow("setControls requires the story view to be mounted")
	end)

	test("does not let an old cleanup unregister the current story", function()
		local controller = createAgentController(createScreen())
		controller.registerApp({
			embedFlipbook = function()
				return "ReplicatedStorage/Flipbook"
			end,
			listStorybooks = function()
				return {}
			end,
			listStories = function()
				return {}
			end,
			openStory = function()
				return {
					id = "default",
					status = StoryStatus.Loaded,
					name = "Second",
					path = "ReplicatedStorage/Second.story",
				}
			end,
			getCurrentStory = function()
				return {
					id = "default",
					status = StoryStatus.Loaded,
					name = "Second",
					path = "ReplicatedStorage/Second.story",
				}
			end,
		})
		local cleanupFirst = controller.registerStory(createStoryAdapter("ReplicatedStorage/First.story", "First"))
		controller.registerStory(createStoryAdapter("ReplicatedStorage/Second.story", "Second"))

		cleanupFirst()

		expect(controller.getControls()).toEqual({ label = "Second" })
	end)
end)
