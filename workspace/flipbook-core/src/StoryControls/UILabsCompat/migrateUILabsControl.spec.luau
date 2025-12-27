local JestGlobals = require("@pkg/JestGlobals")
local UILabs = require("@pkg/UILabs")

local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

local migrateUILabsControl = require("./migrateUILabsControl")

type StoryControlsSchema = types.StoryControlsSchema

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

describe("UILabs.Boolean", function()
	test("maps to ControlType.Boolean", function()
		local control = UILabs.Boolean(true)

		expect(migrateUILabsControl(control)).toMatchObject({
			control = ControlType.Boolean,
			default = true,
		})
	end)
end)

describe("UILabs.Number", function()
	test("maps to ControlType.Number", function()
		local control = UILabs.Number(100)

		expect(migrateUILabsControl(control)).toMatchObject({
			control = ControlType.Number,
			default = 100,
		})
	end)

	test("copies range (min/max) and step", function()
		local control = UILabs.Number(100, 0, 100, 1)

		expect(migrateUILabsControl(control)).toMatchObject({
			control = ControlType.Number,
			default = 100,
			range = NumberRange.new(0, 100),
			step = 1,
		})
	end)
end)

describe("UILabs.String", function()
	-- TODO: Should we support the "Filters" key?

	test("maps to ControlType.String", function()
		local control = UILabs.String("Hello, World!")

		expect(migrateUILabsControl(control)).toMatchObject({
			control = ControlType.String,
			default = "Hello, World!",
		})
	end)
end)

describe("UILabs.Choose", function()
	test("maps to ControlType.Select", function()
		local control = UILabs.Choose({
			"Option 1",
			"Option 2",
			"Option 3",
		})

		expect(migrateUILabsControl(control)).toMatchObject({
			control = ControlType.Select,
			options = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
		})
	end)

	test("includes the default choice", function()
		local control = UILabs.Choose({
			"Option 1",
			"Option 2",
			"Option 3",
		}, 2)

		expect(migrateUILabsControl(control)).toMatchObject({
			control = ControlType.Select,
			options = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
			default = "Option 2",
		})
	end)
end)

describe("UILabs.EnumList", function()
	test("maps to ControlType.Select", function()
		local control = UILabs.EnumList({
			Option1 = "Option 1",
			Option2 = "Option 2",
			Option3 = "Option 3",
		}, "Option1")

		expect(migrateUILabsControl(control)).toMatchObject({
			control = ControlType.Select,
			options = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
			default = "Option 1",
		})
	end)
end)

describe("UILabs.Object", function()
	test("maps to nothing for now", function()
		local control = UILabs.Object("ModuleScript")
		expect(migrateUILabsControl(control)).toBeUndefined()
	end)
end)

describe("UILabs.RGBA", function()
	test("maps to ControlType.Color", function()
		local control = UILabs.RGBA(Color3.fromRGB(255, 0, 200), 0.2)

		expect(migrateUILabsControl(control)).toMatchObject({
			control = ControlType.Color,
			default = control.ControlValue.Color,
		})
	end)
end)

describe("UILabs.Slider", function()
	test("maps to ControlType.Slider", function()
		local control = UILabs.Slider(50, 0, 100, 5)

		expect(migrateUILabsControl(control)).toMatchObject({
			control = ControlType.Slider,
			range = NumberRange.new(0, 100),
			default = 50,
			step = 5,
		})
	end)
end)
