local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local createControlValueCodec = require("./createControlValueCodec")
local getInstancePath = require("@root/Common/getInstancePath")

local afterEach = JestGlobals.afterEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local Workspace = game:GetService("Workspace")

local instances = {}

local function newDataModelFolder(name: string): Folder
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = Workspace
	table.insert(instances, folder)
	return folder
end

afterEach(function()
	for _, instance in instances do
		instance:Destroy()
	end
	table.clear(instances)
end)

describe("createControlValueCodec", function()
	it("round-trips primitives and supported Roblox control values", function()
		local target = newDataModelFolder("AgentControlCodecTarget")
		local date = DateTime.fromUnixTimestampMillis(1_726_000_123_456)
		local schema: Storyteller.StoryControlsSchema = {
			label = Storyteller.createStringControl(),
			color = Storyteller.createColorControl(),
			date = Storyteller.createDateControl(),
			target = Storyteller.createObjectControl(),
			font = Storyteller.createSelectControl({
				Enum.Font.BuilderSans,
				Enum.Font.BuilderSansBold,
			}),
			fonts = Storyteller.createMultiSelectControl({
				Enum.Font.BuilderSans,
				Enum.Font.BuilderSansBold,
			}),
		}
		local controls: Storyteller.StoryControls = {
			label = "Hello",
			color = Color3.new(0.25, 0.5, 0.75),
			date = date,
			target = target,
			font = Enum.Font.BuilderSansBold,
			fonts = {
				Enum.Font.BuilderSans,
				Enum.Font.BuilderSansBold,
			} :: { Storyteller.StoryControlValue },
		}
		local codec = createControlValueCodec(schema)

		local encoded = codec.encode(controls)

		expect(encoded).toEqual({
			label = "Hello",
			color = {
				kind = "Color3",
				r = 0.25,
				g = 0.5,
				b = 0.75,
			},
			date = {
				kind = "DateTime",
				unixTimestampMillis = 1_726_000_123_456,
			},
			target = {
				kind = "Instance",
				path = getInstancePath(target),
			},
			font = {
				kind = "EnumItem",
				enum = tostring(Enum.Font),
				name = "BuilderSansBold",
			},
			fonts = {
				{
					kind = "EnumItem",
					enum = tostring(Enum.Font),
					name = "BuilderSans",
				},
				{
					kind = "EnumItem",
					enum = tostring(Enum.Font),
					name = "BuilderSansBold",
				},
			},
		})

		local decoded = codec.decode(encoded)
		expect(decoded.label).toBe("Hello")
		expect(decoded.color).toBe(Color3.new(0.25, 0.5, 0.75))
		expect(decoded.date).toBe(date)
		expect(decoded.target).toBe(target)
		expect(decoded.font).toBe(Enum.Font.BuilderSansBold)
		expect(decoded.fonts).toEqual({
			Enum.Font.BuilderSans,
			Enum.Font.BuilderSansBold,
		})
	end)

	it("decodes changed typed values against their control definitions", function()
		local target = newDataModelFolder("AgentControlCodecChangedTarget")
		local schema: Storyteller.StoryControlsSchema = {
			color = Storyteller.createColorControl(),
			date = Storyteller.createDateControl(),
			target = Storyteller.createObjectControl(),
		}
		local codec = createControlValueCodec(schema)

		local decoded = codec.decode({
			color = {
				kind = "Color3",
				r = 1,
				g = 0.25,
				b = 0,
			},
			date = {
				kind = "DateTime",
				unixTimestampMillis = 1_700_000_000_000,
			},
			target = {
				kind = "Instance",
				path = getInstancePath(target),
			},
		})

		expect(decoded.color).toBe(Color3.new(1, 0.25, 0))
		expect(decoded.date).toBe(DateTime.fromUnixTimestampMillis(1_700_000_000_000))
		expect(decoded.target).toBe(target)
	end)

	it("rejects list values that are not declared by the mounted Story", function()
		local schema: Storyteller.StoryControlsSchema = {
			font = Storyteller.createSelectControl({
				Enum.Font.BuilderSans,
				Enum.Font.BuilderSansBold,
			}),
		}
		local codec = createControlValueCodec(schema)

		expect(function()
			codec.decode({
				font = {
					kind = "EnumItem",
					enum = tostring(Enum.Font),
					name = "Cartoon",
				},
			})
		end).toThrow("controls.font does not match any item declared by this control")
	end)

	it("rejects missing and out-of-DataModel Instances", function()
		local schema: Storyteller.StoryControlsSchema = {
			target = Storyteller.createObjectControl(),
		}
		local codec = createControlValueCodec(schema)
		local detached = Instance.new("Folder")

		expect(function()
			codec.encode({ target = detached })
		end).toThrow("controls.target is an Instance outside the current DataModel")
		expect(function()
			codec.decode({
				target = {
					kind = "Instance",
					path = "Workspace/DefinitelyMissingAgentControlTarget",
				},
			})
		end).toThrow('controls.target references missing Instance "Workspace/DefinitelyMissingAgentControlTarget"')

		detached:Destroy()
	end)

	it("rejects unknown controls and malformed JSON-shaped values", function()
		local schema: Storyteller.StoryControlsSchema = {
			label = Storyteller.createStringControl(),
		}
		local codec = createControlValueCodec(schema)

		expect(function()
			codec.decode({ unknown = "value" })
		end).toThrow("controls.unknown is not declared by the mounted Story")

		local cycle: { [string]: unknown } = {}
		cycle.self = cycle
		expect(function()
			codec.decode({ label = cycle })
		end).toThrow("controls.label.self refers back to one of its ancestors")

		local sparse: { [number]: unknown } = {}
		sparse[1] = "first"
		sparse[3] = "third"
		expect(function()
			codec.decode({ label = sparse })
		end).toThrow("controls.label is a sparse or non-contiguous array")

		local mixed: { [unknown]: unknown } = {
			[1] = "first",
			name = "named",
		}
		expect(function()
			codec.decode({ label = mixed })
		end).toThrow("controls.label mixes string and number keys")
	end)
end)
