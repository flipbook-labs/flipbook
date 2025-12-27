local JestGlobals = require("@pkg/JestGlobals")
local UILabs = require("@pkg/UILabs")

local ControlType = require("@root/StoryControls/Enums/ControlType")
local UILabsTypes = require("@root/StoryControls/UILabsCompat/UILabsTypes")
local types = require("@root/StoryControls/types")

local migrateUILabsControlsSchema = require("./migrateUILabsControlsSchema")

type StoryControlsSchema = types.StoryControlsSchema

local expect = JestGlobals.expect
local test = JestGlobals.test

test("migrates a complex UI Labs schema to Flipbook's schema", function()
	local schema: UILabsTypes.ControlsSchema = {
		message = UILabs.String("Hello, World!") :: any,

		group = UILabs.ControlGroup({
			toggle = UILabs.Boolean(false),

			choice = UILabs.Choose({
				"Option 1",
				"Option 2",
				"Option 3",
			}),
		}) :: any,
	}

	expect(migrateUILabsControlsSchema(schema)).toMatchObject({
		message = {
			control = ControlType.String,
			default = "Hello, World!",
		},
		toggle = {
			control = ControlType.Boolean,
			default = false,
		},
		choice = {
			control = ControlType.Select,
			options = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
		},
	})
end)
