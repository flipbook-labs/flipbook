local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

local AgentContext = require("@root/Agent/AgentContext")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local getInstancePath = require("@root/Common/getInstancePath")
local useAgentRegistration = require("@root/Agent/useAgentRegistration")

local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

type AgentController = FlipbookAgents.AgentController
type LoadedStorybook = Storyteller.LoadedStorybook
type Options = useAgentRegistration.Options

local root: Folder
local story: ModuleScript
local storybook: LoadedStorybook
local controller: AgentController
local openedStory: ModuleScript?

beforeEach(function()
	root = Instance.new("Folder")
	root.Name = "UseAgentRegistrationSpec"
	root.Parent = ReplicatedStorage

	local storybookModule = Instance.new("ModuleScript")
	storybookModule.Name = "Example.storybook"
	storybookModule.Parent = root

	local stories = Instance.new("Folder")
	stories.Name = "Stories"
	stories.Parent = root

	story = Instance.new("ModuleScript")
	story.Name = "Button.story"
	story.Parent = stories

	storybook = {
		name = "Example",
		source = storybookModule,
		storyRoots = { stories :: Instance },
	}

	local screen = Instance.new("ScreenGui")
	screen.Enabled = false
	controller = FlipbookAgents.createAgentController(screen)
	openedStory = nil
end)

afterEach(function()
	root:Destroy()
end)

local function createOptions(available: { LoadedStorybook }): Options
	return {
		storybooks = {
			available = available,
			unavailable = {},
		},
		getCurrentStory = function()
			return openedStory, if openedStory then storybook else nil
		end,
		openStory = function(nextStory)
			openedStory = nextStory
		end,
	}
end

local function TestComponent(props: { options: Options })
	useAgentRegistration(props.options)
	return nil
end

local function renderWithController(options: Options)
	local reactRoot = ReactRoblox.createRoot(Instance.new("Folder"))

	local function render(nextOptions: Options)
		act(function()
			reactRoot:render(React.createElement(AgentContext.Provider, {
				value = controller,
			}, {
				Test = React.createElement(TestComponent, {
					options = nextOptions,
				}),
			}))
		end)
	end

	render(options)

	return {
		rerender = render,
		unmount = function()
			act(function()
				reactRoot:unmount()
			end)
		end,
	}
end

test("routes the controller's app actions to the mounted app", function()
	local rendered = renderWithController(createOptions({ storybook }))

	expect(controller.listStorybooks()[1].name).toBe("Example")
	expect(controller.getCurrentStory()).toBeNil()

	controller.openStory(getInstancePath(story), nil)

	expect(openedStory).toBe(story)
	local currentStory = controller.getCurrentStory()
	expect(currentStory).never.toBeNil()
	assert(currentStory)
	expect(currentStory.path).toBe(getInstancePath(story))

	rendered.unmount()
end)

test("reads the app's latest state after it re-renders", function()
	local rendered = renderWithController(createOptions({}))

	expect(#controller.listStorybooks()).toBe(0)

	rendered.rerender(createOptions({ storybook }))

	expect(#controller.listStorybooks()).toBe(1)

	rendered.unmount()
end)

test("removes the app from the controller when it unmounts", function()
	local rendered = renderWithController(createOptions({ storybook }))

	rendered.unmount()

	expect(function()
		controller.listStorybooks()
	end).toThrow("Flipbook app is not mounted")
end)
