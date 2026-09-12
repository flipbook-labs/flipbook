local JestGlobals = require("@pkg/JestGlobals")

local createAgentController = require("@root/createAgentController")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local function createWidget()
	return { Enabled = false } :: any
end

local function createStoryImplementation(path: string, initialValue: string)
	local controls: { [string]: unknown } = { label = initialValue }
	return {
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
	test("routes app actions through the current implementation", function()
		local widget = createWidget()
		local controller = createAgentController(widget)
		local cleanup = controller.registerApp({
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
				return nil
			end,
		})

		expect(controller.listStorybooks()[1].name).toBe("Example")
		expect(controller.listStories("ReplicatedStorage/Example.storybook")[1].name).toBe("Button")
		expect(controller.openStory("ReplicatedStorage/Button.story", nil).path).toBe("ReplicatedStorage/Button.story")
		expect(widget.Enabled).toBe(true)

		cleanup()
		expect(function()
			controller.listStorybooks()
		end).toThrow("Flipbook app is not mounted")
	end)
end)

describe("story registration", function()
	test("reports readiness and updates controls through the mounted story", function()
		local controller = createAgentController(createWidget())
		controller.registerApp({
			listStorybooks = function()
				return {}
			end,
			listStories = function()
				return {}
			end,
			openStory = function()
				return { name = "Button", path = "ReplicatedStorage/Button.story" }
			end,
			getCurrentStory = function()
				return { name = "Button", path = "ReplicatedStorage/Button.story" }
			end,
		})

		expect(controller.getCurrentStory()).toEqual({
			name = "Button",
			path = "ReplicatedStorage/Button.story",
			isMounted = false,
		})
		expect(controller.getControls()).toEqual({})

		local cleanup = controller.registerStory(createStoryImplementation("ReplicatedStorage/Button.story", "Before"))
		local mountedStory = controller.getCurrentStory()
		assert(mountedStory ~= nil, "expected a current story")
		expect(mountedStory.isMounted).toBe(true)
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
		local controller = createAgentController(createWidget())
		local cleanupFirst =
			controller.registerStory(createStoryImplementation("ReplicatedStorage/First.story", "First"))
		controller.registerStory(createStoryImplementation("ReplicatedStorage/Second.story", "Second"))

		cleanupFirst()

		expect(controller.getControls()).toEqual({ label = "Second" })
	end)
end)
