local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

local AgentContext = require("@root/Agent/AgentContext")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")
local getInstancePath = require("@root/Common/getInstancePath")
local useAgentStoryRegistration = require("@root/Agent/useAgentStoryRegistration")

local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

type AgentController = FlipbookAgents.AgentController
type LoadedStory = useAgentStoryRegistration.LoadedStory
type StoryControlsSchema = Storyteller.StoryControlsSchema
type StoryControlsStore = createStoryControlsStore.StoryControlsStore

type MountedStory = {
	storyModule: ModuleScript,
	story: LoadedStory,
	controlsStore: StoryControlsStore,
}

local root: Folder
local controller: AgentController
local currentStoryPath: string?

beforeEach(function()
	root = Instance.new("Folder")
	root.Name = "UseAgentStoryRegistrationSpec"
	root.Parent = ReplicatedStorage

	local screen = Instance.new("ScreenGui")
	screen.Enabled = false
	controller = FlipbookAgents.createAgentController(screen)
	currentStoryPath = nil

	-- The controller only answers for the story the app reports as current,
	-- so this stands in for the app and reports `currentStoryPath`.
	controller.registerApp({
		embedFlipbook = function()
			return ""
		end,
		listStorybooks = function()
			return {}
		end,
		listStories = function()
			return {}
		end,
		openStory = function(storyPath)
			return {
				name = "Story",
				path = storyPath,
			}
		end,
		getCurrentStory = function()
			return if currentStoryPath
				then {
					name = "Story",
					path = currentStoryPath,
				}
				else nil
		end,
	})
end)

afterEach(function()
	root:Destroy()
end)

local function createStory(name: string, controls: StoryControlsSchema): MountedStory
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = `{name}.story`
	storyModule.Parent = root

	local story: LoadedStory = {
		controls = controls,
	}

	return {
		storyModule = storyModule,
		story = story,
		controlsStore = createStoryControlsStore(story.controls),
	}
end

local function TestComponent(props: { mounted: MountedStory })
	useAgentStoryRegistration(props.mounted.storyModule, props.mounted.story, props.mounted.controlsStore)
	return nil
end

local function renderStory(mounted: MountedStory)
	local reactRoot = ReactRoblox.createRoot(Instance.new("Folder"))

	local function render(nextMounted: MountedStory)
		currentStoryPath = getInstancePath(nextMounted.storyModule)
		act(function()
			reactRoot:render(React.createElement(AgentContext.Provider, {
				value = controller,
			}, {
				Test = React.createElement(TestComponent, {
					mounted = nextMounted,
				}),
			}))
		end)
	end

	render(mounted)

	return {
		rerender = render,
		unmount = function()
			act(function()
				reactRoot:unmount()
			end)
		end,
	}
end

test("reads the mounted story's controls", function()
	local rendered = renderStory(createStory("Button", { label = "Hello" }))

	expect(controller.getControls()).toEqual({
		label = "Hello",
	})

	rendered.unmount()
end)

test("writes controls to the store the story renders from", function()
	local mounted = createStory("Button", { label = "Hello" })
	local rendered = renderStory(mounted)

	expect(controller.setControls({
		label = "World",
	})).toEqual({
		label = "World",
	})
	expect(mounted.controlsStore.getControls().label).toBe("World")

	rendered.unmount()
end)

test("switches to the next story after navigation", function()
	local first = createStory("First", { label = "First" })
	local second = createStory("Second", { label = "Second" })
	local rendered = renderStory(first)

	rendered.rerender(second)

	expect(controller.getControls()).toEqual({
		label = "Second",
	})

	-- The first story's registration ended, so it no longer answers even when
	-- the app reports it as current again.
	currentStoryPath = getInstancePath(first.storyModule)
	expect(controller.getControls()).toEqual({})

	rendered.unmount()
end)

test("stops answering once the story unmounts", function()
	local rendered = renderStory(createStory("Button", { label = "Hello" }))

	rendered.unmount()

	expect(controller.getControls()).toEqual({})
	expect(function()
		controller.setControls({
			label = "World",
		})
	end).toThrow("setControls requires the story view to be mounted")
end)

test("reads and writes Roblox values across a BindableFunction", function()
	local rendered = renderStory(createStory("Button", {
		color = Storyteller.createColorControl(Color3.new(1, 0, 0)),
		fonts = Storyteller.createMultiSelectControl({
			Enum.Font.BuilderSans :: EnumItem,
			Enum.Font.BuilderSansBold,
		}),
	}))

	-- Agents call the controller through AgentGateway's BindableFunction, and
	-- Roblox copies the tables that pass through one. These stand in for it to
	-- check that the values inside those tables survive.
	local setControls = Instance.new("BindableFunction")
	setControls.OnInvoke = controller.setControls
	local getControls = Instance.new("BindableFunction")
	getControls.OnInvoke = controller.getControls

	local controls = {
		color = Color3.new(0.25, 0.5, 0.75),
		fonts = { Enum.Font.BuilderSansBold },
	}

	expect(setControls:Invoke(controls)).toEqual(controls)
	expect(getControls:Invoke()).toEqual(controls)

	rendered.unmount()
end)

test("changes nothing when one of the controls is invalid", function()
	local mounted = createStory("Button", {
		label = "Hello",
		size = 1,
	})
	local rendered = renderStory(mounted)

	expect(function()
		controller.setControls({
			label = "World",
			size = "large",
		})
	end).toThrow("controls.size must be a number, got string")
	expect(mounted.controlsStore.getControls()).toEqual({
		label = "Hello",
		size = 1,
	})

	rendered.unmount()
end)
