local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local StoryControlsStore = require("./StoryControlsStore")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local function createSchema(): Storyteller.StoryControlsSchema
	return {
		name = Storyteller.createStringControl("Alice"),
		count = Storyteller.createNumberControl(5),
	}
end

describe("getControlValue", function()
	test("returns the schema default before any override is set", function()
		local store = StoryControlsStore.new(createSchema())

		expect(store.getControlValue("name")()).toBe("Alice")
		expect(store.getControlValue("count")()).toBe(5)
	end)

	test("returns the override after setControl is called", function()
		local store = StoryControlsStore.new(createSchema())

		store.setControl("name", "Bob")

		expect(store.getControlValue("name")()).toBe("Bob")
	end)

	test("override does not affect other controls", function()
		local store = StoryControlsStore.new(createSchema())

		store.setControl("name", "Bob")

		expect(store.getControlValue("count")()).toBe(5)
	end)

	test("returns the same getter reference on repeated calls for the same key", function()
		local store = StoryControlsStore.new(createSchema())

		local getter1 = store.getControlValue("name")
		local getter2 = store.getControlValue("name")

		expect(getter1).toBe(getter2)
	end)
end)

describe("getControls", function()
	test("returns a flat map of all effective control values", function()
		local store = StoryControlsStore.new(createSchema())

		expect(store.getControls()).toEqual({ name = "Alice", count = 5 })
	end)

	test("reflects overrides in the full map", function()
		local store = StoryControlsStore.new(createSchema())

		store.setControl("name", "Charlie")

		expect(store.getControls()).toEqual({ name = "Charlie", count = 5 })
	end)

	test("returns an empty table when created with no schema", function()
		local store = StoryControlsStore.new()

		expect(store.getControls()).toEqual({})
	end)
end)
