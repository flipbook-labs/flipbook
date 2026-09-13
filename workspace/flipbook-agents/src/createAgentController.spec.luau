local JestGlobals = require("@pkg/JestGlobals")

local createAgentController = require("@root/createAgentController")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local function createWidget()
	return { Enabled = false } :: any
end

local function createStoryImplementation(path: string, id: string, initialValue: string)
	local controls: { [string]: unknown } = { label = initialValue }
	return {
		id = id,
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
		local screenGui = Instance.new("ScreenGui")
		screenGui.Enabled = false
		local controller = createAgentController(function()
			screenGui.Enabled = true
		end)

		controller.openWidget()

		expect(screenGui.Enabled).toBe(true)
	end)

	test("routes app actions through the current implementation", function()
		local widget = createWidget()
		local controller = createAgentController(function()
			widget.Enabled = true
		end)
		local cleanup = controller.registerApp({
			embedFlipbook = function(parentPath, overwrite)
				expect(parentPath).toBe("ReplicatedStorage")
				expect(overwrite).toBe(true)
				return "ReplicatedStorage/Flipbook"
			end,
			listStorybooks = function()
				return { { name = "Example", path = "ReplicatedStorage/Example.storybook" } }
			end,
			listStories = function(storybookPath)
				return {
					{
						id = "primary",
						name = "Primary",
						path = `${storybookPath}/Button.story`,
						storybook = storybookPath,
					},
				}
			end,
			openStory = function(storyPath, storybookPath, storyId)
				return { id = storyId or "primary", name = "Primary", path = storyPath, storybook = storybookPath }
			end,
			getCurrentStory = function()
				return nil
			end,
		})

		expect(controller.listStorybooks()[1].name).toBe("Example")
		expect(controller.embedFlipbook("ReplicatedStorage", true)).toBe("ReplicatedStorage/Flipbook")
		expect(controller.listStories("ReplicatedStorage/Example.storybook")[1].id).toBe("primary")
		expect(controller.openStory("ReplicatedStorage/Button.story", nil, "primary").id).toBe("primary")
		expect(widget.Enabled).toBe(true)

		cleanup()
		expect(function()
			controller.listStorybooks()
		end).toThrow("Flipbook app is not mounted")
	end)
end)

describe("story registration", function()
	test("reports readiness and updates controls through the mounted story", function()
		local controller = createAgentController(function() end)
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
				return { id = "primary", name = "Primary", path = "ReplicatedStorage/Button.story" }
			end,
			getCurrentStory = function()
				return { id = "primary", name = "Primary", path = "ReplicatedStorage/Button.story" }
			end,
		})

		expect(controller.getCurrentStory()).toEqual({
			id = "primary",
			name = "Primary",
			path = "ReplicatedStorage/Button.story",
			controlsReady = false,
			isMounted = false,
		})
		expect(controller.getControls()).toEqual({})

		local cleanup =
			controller.registerStory(createStoryImplementation("ReplicatedStorage/Button.story", "primary", "Before"))
		local mountedStory = controller.getCurrentStory()
		assert(mountedStory ~= nil, "expected a current story")
		expect(mountedStory.isMounted).toBe(true)
		expect(mountedStory.controlsReady).toBe(true)
		expect(controller.setControls({ label = "After" })).toEqual({ label = "After" })

		cleanup()
		local unmountedStory = controller.getCurrentStory()
		assert(unmountedStory ~= nil, "expected a current story")
		expect(unmountedStory.isMounted).toBe(false)
		expect(function()
			controller.setControls({ label = "Again" })
		end).toThrow("setControls requires the story view to be mounted")
	end)

	test("does not let an old cleanup unregister the current story", function()
		local controller = createAgentController(function() end)
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
				return { id = "primary", name = "Second", path = "ReplicatedStorage/Second.story" }
			end,
			getCurrentStory = function()
				return { id = "primary", name = "Second", path = "ReplicatedStorage/Second.story" }
			end,
		})
		local cleanupFirst =
			controller.registerStory(createStoryImplementation("ReplicatedStorage/First.story", "primary", "First"))
		controller.registerStory(createStoryImplementation("ReplicatedStorage/Second.story", "primary", "Second"))

		cleanupFirst()

		expect(controller.getControls()).toEqual({ label = "Second" })
	end)
end)

test("does not report a different Story ID from the same module as mounted", function()
	local controller = createAgentController(function() end)
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
			return { id = "secondary", name = "Secondary", path = "ReplicatedStorage/Button.story" }
		end,
		getCurrentStory = function()
			return { id = "secondary", name = "Secondary", path = "ReplicatedStorage/Button.story" }
		end,
	})
	controller.registerStory(createStoryImplementation("ReplicatedStorage/Button.story", "primary", "Before"))

	expect(controller.getCurrentStory()).toMatchObject({
		id = "secondary",
		controlsReady = false,
		isMounted = false,
	})
	expect(controller.getControls()).toEqual({})
	expect(function()
		controller.setControls({ label = "After" })
	end).toThrow("setControls requires the story view to be mounted")
end)
