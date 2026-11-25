local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local parseControlValues = require("./parseControlValues")

local expect = JestGlobals.expect
local test = JestGlobals.test

type AgentControls = { [string]: unknown }
type StoryControlsSchema = Storyteller.StoryControlsSchema

local FONTS = {
	Enum.Font.BuilderSans :: EnumItem,
	Enum.Font.BuilderSansBold,
}

local schema: StoryControlsSchema = {
	boolean = Storyteller.createBooleanControl(),
	check = Storyteller.createCheckControl(FONTS),
	color = Storyteller.createColorControl(),
	date = Storyteller.createDateControl(),
	multiSelect = Storyteller.createMultiSelectControl(FONTS),
	number = Storyteller.createNumberControl(),
	object = Storyteller.createObjectControl(),
	plainValue = "Default",
	radio = Storyteller.createRadioControl(FONTS),
	select = Storyteller.createSelectControl(FONTS),
	slider = Storyteller.createSliderControl(),
	string = Storyteller.createStringControl(),
}

test("accepts a value of the right type for every kind of control", function()
	local controls: AgentControls = {
		boolean = false,
		check = { Enum.Font.BuilderSans, Enum.Font.BuilderSansBold },
		color = Color3.new(0.25, 0.5, 0.75),
		date = DateTime.fromUnixTimestampMillis(1_726_000_123_456),
		multiSelect = { Enum.Font.BuilderSansBold },
		number = 2,
		object = game:GetService("Workspace"),
		plainValue = "Changed",
		radio = Enum.Font.BuilderSans,
		select = Enum.Font.BuilderSansBold,
		slider = 0.5,
		string = "Hello",
	}

	expect(parseControlValues(schema, controls)).toEqual(controls)
end)

test("accepts an empty list for controls that hold several items", function()
	local controls: AgentControls = {
		check = {},
		multiSelect = {},
	}

	expect(parseControlValues(schema, controls)).toEqual(controls)
end)

test("rejects a control the story doesn't declare", function()
	expect(function()
		parseControlValues(schema, { unknown = "value" })
	end).toThrow("controls.unknown is not declared by the mounted Story")
end)

local VALUE_TYPES: { [string]: string } = {
	boolean = "boolean",
	color = "Color3",
	date = "DateTime",
	number = "number",
	object = "Instance",
	plainValue = "string",
	slider = "number",
	string = "string",
}

for name, expectedType in VALUE_TYPES do
	test(`rejects a value of the wrong type for {name}`, function()
		expect(function()
			parseControlValues(schema, { [name] = Vector2.new(1, 1) })
		end).toThrow(`controls.{name} must be a {expectedType}, got Vector2`)
	end)
end

for _, name in { "radio", "select" } do
	test(`rejects an item {name} doesn't declare`, function()
		expect(function()
			parseControlValues(schema, { [name] = Enum.Font.Cartoon })
		end).toThrow(
			`controls.{name} must be one of [Enum.Font.BuilderSans, Enum.Font.BuilderSansBold], got Enum.Font.Cartoon`
		)
	end)
end

for _, name in { "check", "multiSelect" } do
	test(`rejects an item in the list that {name} doesn't declare`, function()
		expect(function()
			parseControlValues(schema, {
				[name] = { Enum.Font.BuilderSans, Enum.Font.Cartoon },
			})
		end).toThrow(
			`controls.{name}[2] must be one of [Enum.Font.BuilderSans, Enum.Font.BuilderSansBold], got Enum.Font.Cartoon`
		)
	end)

	test(`rejects a single item for {name}`, function()
		expect(function()
			parseControlValues(schema, { [name] = Enum.Font.BuilderSans })
		end).toThrow(`controls.{name} must be a table, got EnumItem`)
	end)

	test(`rejects a dictionary for {name}`, function()
		expect(function()
			parseControlValues(schema, {
				[name] = {
					font = Enum.Font.BuilderSans,
				},
			})
		end).toThrow(`controls.{name} must be an array of declared control items`)
	end)
end
