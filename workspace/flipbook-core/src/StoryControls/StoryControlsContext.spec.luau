local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

local StoryControlsContext = require("@root/StoryControls/StoryControlsContext")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")
local useStoryControlValue = require("@root/StoryControls/useStoryControlValue")
local useStoryControlValues = require("@root/StoryControls/useStoryControlValues")

local afterEach = JestGlobals.afterEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local ControlType = Storyteller.ControlType
local container = Instance.new("Folder")
local root = ReactRoblox.createRoot(container)

local currentStore: createStoryControlsStore.StoryControlsStore? = nil
local currentValue: unknown = nil
local currentValues: Storyteller.StoryControls? = nil

local function Consumer()
	currentStore = StoryControlsContext.useStoryControls()
	currentValue = useStoryControlValue("name")
	currentValues = useStoryControlValues()

	return nil
end

local function renderWithDefault(defaultValue: string)
	ReactRoblox.act(function()
		root:render(React.createElement(StoryControlsContext.StoryControlsProvider, {
			schema = {
				name = {
					type = ControlType.String,
					default = defaultValue,
				},
			} :: Storyteller.StoryControlsSchema,
		}, React.createElement(Consumer)))
	end)
end

afterEach(function()
	ReactRoblox.act(function()
		root:unmount()
	end)
	currentStore = nil
	currentValue = nil
	currentValues = nil
end)

test("resubscribes when the provider replaces its story controls store", function()
	renderWithDefault("Alice")

	expect(currentValue).toBe("Alice")
	expect(assert(currentValues).name).toBe("Alice")

	renderWithDefault("Bob")

	expect(currentValue).toBe("Bob")
	expect(assert(currentValues).name).toBe("Bob")

	ReactRoblox.act(function()
		assert(currentStore, "expected the consumer to expose its current store").setControl("name", "Charlie")
	end)

	expect(currentValue).toBe("Charlie")
	expect(assert(currentValues).name).toBe("Charlie")
end)
