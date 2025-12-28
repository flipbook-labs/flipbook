local JestGlobals = require("@pkg/JestGlobals")

local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

local hydrateControls = require("./hydrateControls")

type StoryControlsSchema = types.StoryControlsSchema

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local function assertAllControlTypesAreIncluded(schema: StoryControlsSchema)
	local missed = {}

	for _, controlType in ControlType do
		local found = false

		for _, controlSchema in schema do
			if controlSchema.control == controlType then
				found = true
			end
		end

		if not found then
			table.insert(missed, controlType)
		end
	end

	assert(#missed == 0, `the following ControlTypes need to be included: {table.concat(missed, ", ")}`)
end

test("hydrates a schema using all control types", function()
	local schema: StoryControlsSchema = {
		greeting = {
			control = ControlType.String,
			default = "Hello, World!",
		},

		toggle = {
			control = ControlType.Boolean,
			default = false,
		},

		number = {
			control = ControlType.Number,
			default = 1,
			range = NumberRange.new(1, 100),
		},

		slider = {
			control = ControlType.Slider,
			default = 1,
			step = 1,
			range = NumberRange.new(1, 100),
		},

		dropdown = {
			control = ControlType.Select,
			options = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
		},

		color = {
			control = ControlType.Color,
			default = Color3.fromRGB(255, 255, 255),
		},

		date = {
			control = ControlType.Date,
			default = DateTime.now(),
		},

		multiSelect = {
			control = ControlType.MultiSelect,
			options = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
		},

		check = {
			control = ControlType.Check,
			options = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
		},

		radio = {
			control = ControlType.Radio,
			options = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
		},
	}

	assertAllControlTypesAreIncluded(schema)

	local controls = {
		greeting = nil,
		toggle = true,
		slider = 50,
	}

	local expected = {
		greeting = "Hello, World!",
		toggle = true,
		number = 1,
		slider = 50,
		dropdown = "Option 1",
		color = expect.any("Color3"),
		date = expect.any("DateTime"),
		multiSelect = {},
		check = {},
		radio = {},
	}

	expect(hydrateControls(schema, controls)).toMatchObject(expected)
end)

describe("Boolean", function()
	test("hydrates a schema with a Boolean control", function()
		local schema: StoryControlsSchema = {
			isDisabled = {
				control = ControlType.Boolean,
				default = false,
			},
		}

		local controls = {
			isDisabled = true,
		}

		local hydrated = hydrateControls(schema, controls)

		expect(hydrated).toMatchObject({
			isDisabled = true,
		})
	end)
end)

describe("Number", function()
	test("hydrates a schema with a Number control", function()
		local schema: StoryControlsSchema = {
			num = {
				control = ControlType.Number,
				default = 100,
			},
		}

		local controls = {}

		local hydrated = hydrateControls(schema, controls)

		expect(hydrated).toMatchObject({
			num = 100,
		})
	end)

	test("throws when schema default value is out of range", function()
		local schema: types.StoryControlsSchema = {
			number = {
				control = ControlType.Number,
				default = -100,
				range = NumberRange.new(1, 100),
			},
		}

		local controls = {}

		expect(function()
			hydrateControls(schema, controls)
		end).toThrow()
	end)

	test("throws when control value is out of range", function()
		local schema: types.StoryControlsSchema = {
			number = {
				control = ControlType.Number,
				default = 1,
				range = NumberRange.new(1, 100),
			},
		}

		local controls = {
			number = -100,
		}

		expect(function()
			hydrateControls(schema, controls)
		end).toThrow()
	end)
end)

describe("String", function()
	test("hydrates a schema with a String control", function()
		local schema: StoryControlsSchema = {
			text = {
				control = ControlType.String,
				default = "Hello, World!",
			},
		}

		local controls = {}

		local hydrated = hydrateControls(schema, controls)

		expect(hydrated).toMatchObject({
			text = "Hello, World!",
		})
	end)
end)

describe("Check", function()
	test("hydrates a schema with a Check control", function()
		local schema: StoryControlsSchema = {
			options = {
				control = ControlType.Check,
				options = {
					"Option 1",
					"Option 2",
					"Option 3",
				},
			},
		}

		local controls = {}

		local hydrated = hydrateControls(schema, controls)

		expect(hydrated).toMatchObject({
			options = { "Option 1" },
		})
	end)

	test("throws when passing an invalid option", function()
		local schema: StoryControlsSchema = {
			options = {
				control = ControlType.Check,
				options = {
					"Option 1",
					"Option 2",
					"Option 3",
				},
			},
		}

		local controls = {
			options = { "Not an option" },
		}

		expect(function()
			hydrateControls(schema, controls)
		end).toThrow()
	end)
end)

describe("Color", function()
	test("hydrates a schema with a Color control", function()
		local color = Color3.fromRGB(255, 255, 255)
		local schema: StoryControlsSchema = {
			color = {
				control = ControlType.Color,
				default = color,
			},
		}

		local controls = {}

		local hydrated = hydrateControls(schema, controls)

		expect(hydrated).toMatchObject({
			color = color,
		})
	end)
end)

describe("Date", function()
	test("hydrates a schema with a Date control", function()
		local date = DateTime.now()

		local schema: StoryControlsSchema = {
			date = {
				control = ControlType.Date,
				default = date,
			},
		}

		local controls = {}

		local hydrated = hydrateControls(schema, controls)

		expect(hydrated).toMatchObject({
			date = date,
		})
	end)
end)

describe("MultiSelect", function()
	test("hydrates a schema with a MultiSelect control", function()
		local schema: StoryControlsSchema = {
			choices = {
				control = ControlType.MultiSelect,
				options = {
					"Option 1",
					"Option 2",
					"Option 3",
				},
			},
		}

		local controls = {
			choices = { "Option 2" },
		}

		local hydrated = hydrateControls(schema, controls)

		expect(hydrated).toMatchObject({
			multiSelect = { "Option 2" },
		})
	end)

	test("throws when passing an invalid option", function()
		local schema: StoryControlsSchema = {
			choices = {
				control = ControlType.MultiSelect,
				options = {
					"Option 1",
					"Option 2",
					"Option 3",
				},
			},
		}

		local controls = {
			choices = { "Not an option" },
		}

		expect(function()
			hydrateControls(schema, controls)
		end).toThrow()
	end)
end)

describe("Radio", function()
	test("hydrates a schema with a Radio control", function()
		local schema: StoryControlsSchema = {
			radio = {
				control = ControlType.Radio,
				options = {
					"Option 1",
					"Option 2",
					"Option 3",
				},
			},
		}

		local controls = {
			radio = "Option 2",
		}

		local hydrated = hydrateControls(schema, controls)

		expect(hydrated).toMatchObject({
			radio = "Option 2",
		})
	end)

	test("throws when passing an invalid option", function()
		local schema: StoryControlsSchema = {
			radio = {
				control = ControlType.Radio,
				options = {
					"Option 1",
					"Option 2",
					"Option 3",
				},
			},
		}

		local controls = {
			radio = "Not an option",
		}

		expect(function()
			hydrateControls(schema, controls)
		end).toThrow()
	end)
end)

describe("Select", function()
	test("hydrates a schema with a Select control", function()
		local schema: StoryControlsSchema = {
			choices = {
				control = ControlType.Select,
				options = {
					"Option 1",
					"Option 2",
					"Option 3",
				},
			},
		}

		local controls = {
			choices = "Option 2",
		}

		local hydrated = hydrateControls(schema, controls)

		expect(hydrated).toMatchObject({
			multiSelect = { "Option 2" },
		})
	end)

	test("throws when passing an invalid option", function()
		local schema: StoryControlsSchema = {
			choices = {
				control = ControlType.Select,
				options = {
					"Option 1",
					"Option 2",
					"Option 3",
				},
			},
		}

		local controls = {
			choices = "Not an option",
		}

		expect(function()
			hydrateControls(schema, controls)
		end).toThrow()
	end)
end)

describe("Slider", function()
	test("throws when schema default value is out of range", function()
		local schema: types.StoryControlsSchema = {
			slider = {
				control = ControlType.Slider,
				default = -100,
				range = NumberRange.new(1, 100),
			},
		}

		local controls = {}

		expect(function()
			hydrateControls(schema, controls)
		end).toThrow()
	end)

	test("throws when control value is out of range", function()
		local schema: types.StoryControlsSchema = {
			number = {
				control = ControlType.Number,
				default = 1,
				range = NumberRange.new(1, 100),
			},
		}

		local controls = {
			number = -100,
		}

		expect(function()
			hydrateControls(schema, controls)
		end).toThrow()
	end)
end)
