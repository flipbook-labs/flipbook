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
		local store = StoryControlsStore.new()
		store.setSchema(createSchema())

		expect(store.getControlValue("name")()).toBe("Alice")
		expect(store.getControlValue("count")()).toBe(5)
	end)

	test("returns the override after setControl is called", function()
		local store = StoryControlsStore.new()
		store.setSchema(createSchema())

		store.setControl("name", "Bob")

		expect(store.getControlValue("name")()).toBe("Bob")
	end)

	test("override does not affect other controls", function()
		local store = StoryControlsStore.new()
		store.setSchema(createSchema())

		store.setControl("name", "Bob")

		expect(store.getControlValue("count")()).toBe(5)
	end)

	test("returns the same getter reference on repeated calls for the same key", function()
		local store = StoryControlsStore.new()
		store.setSchema(createSchema())

		local getter1 = store.getControlValue("name")
		local getter2 = store.getControlValue("name")

		expect(getter1).toBe(getter2)
	end)
end)

describe("getControls", function()
	test("returns a flat map of all effective control values", function()
		local store = StoryControlsStore.new()
		store.setSchema(createSchema())

		expect(store.getControls()).toEqual({ name = "Alice", count = 5 })
	end)

	test("reflects overrides in the full map", function()
		local store = StoryControlsStore.new()
		store.setSchema(createSchema())

		store.setControl("name", "Charlie")

		expect(store.getControls()).toEqual({ name = "Charlie", count = 5 })
	end)

	test("returns an empty table before clear is called", function()
		local store = StoryControlsStore.new()

		expect(store.getControls()).toEqual({})
	end)
end)

describe("setSchema", function()
	test("clears overrides when called with a new schema", function()
		local store = StoryControlsStore.new()
		store.setSchema(createSchema())
		store.setControl("name", "Bob")

		store.clear()

		expect(store.getControlValue("name")()).toBe("Alice")
	end)

	test("switches to a new schema's defaults", function()
		local store = StoryControlsStore.new()
		store.setSchema(createSchema())

		store.setSchema({
			title = Storyteller.createStringControl("Untitled"),
		} :: Storyteller.StoryControlsSchema)

		expect(store.getControlValue("title")()).toBe("Untitled")
	end)
end)

describe("clear", function()
	test("clears out all control values", function()
		local store = StoryControlsStore.new()
		store.setSchema(createSchema())

		store.setControl("name", "Bob")

		expect(store.getControlValue("name")()).toBe("Bob")

		store.clear()

		expect(store.getControlValue("name")()).toBe("Alice")
	end)
end)
