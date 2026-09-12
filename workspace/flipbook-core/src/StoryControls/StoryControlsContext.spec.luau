local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

local StoryControlsContext = require("@root/StoryControls/StoryControlsContext")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")

local afterEach = JestGlobals.afterEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local ControlType = Storyteller.ControlType
local container = Instance.new("Folder")
local root = ReactRoblox.createRoot(container)

local currentStore: createStoryControlsStore.StoryControlsStore? = nil

local function Consumer()
	currentStore = StoryControlsContext.useStoryControls()
	local value = StoryControlsContext.useStoryControlValue("name")
	local values = StoryControlsContext.useStoryControlValues()

	return React.createElement("Folder", nil, {
		Single = React.createElement("StringValue", {
			Value = tostring(value),
		}),
		All = React.createElement("StringValue", {
			Value = tostring(values.name),
		}),
	})
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
end)

test("resubscribes when the provider replaces its story controls store", function()
	renderWithDefault("Alice")

	local result = container:FindFirstChildWhichIsA("Folder") :: Folder
	expect((result:FindFirstChild("Single") :: StringValue).Value).toBe("Alice")
	expect((result:FindFirstChild("All") :: StringValue).Value).toBe("Alice")

	renderWithDefault("Bob")

	result = container:FindFirstChildWhichIsA("Folder") :: Folder
	expect((result:FindFirstChild("Single") :: StringValue).Value).toBe("Bob")
	expect((result:FindFirstChild("All") :: StringValue).Value).toBe("Bob")

	ReactRoblox.act(function()
		assert(currentStore, "expected the consumer to expose its current store").setControl("name", "Charlie")
	end)

	expect((result:FindFirstChild("Single") :: StringValue).Value).toBe("Charlie")
	expect((result:FindFirstChild("All") :: StringValue).Value).toBe("Charlie")
end)
