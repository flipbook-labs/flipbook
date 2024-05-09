local JestGlobals = require("@pkg/JestGlobals")

local renderHook = require("@root/Testing/renderHook")
local useTag = require("./useTag")

local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach
local test = JestGlobals.test
local expect = JestGlobals.expect

local container

beforeEach(function()
	container = Instance.new("Folder")
	container.Parent = game
end)

afterEach(function()
	container:Destroy()
end)

test("all tagged instances are used for the initial state", function()
	local instance = Instance.new("Part")
	instance:SetTag("foo")
	instance.Parent = container

	local other = Instance.new("Part")
	other:SetTag("bar")
	other.Parent = container

	local get = renderHook(function()
		return useTag("foo")
	end)

	local instances = get()

	expect(instances).toEqual({
		instance,
	})
end)

test("adding the tag to an instance updates state", function() end)

test("removing the tag from an instance updates state", function() end)
