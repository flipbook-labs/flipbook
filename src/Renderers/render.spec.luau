local JestGlobals = require("@pkg/JestGlobals")
local render = require("./render")
local types = require("@root/Renderers/types")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

type Renderer = types.Renderer

local container: Instance
local element = jest.fn()

beforeEach(function()
	container = Instance.new("Folder")
end)

afterEach(function()
	container:Destroy()
	jest.resetAllMocks()
end)

test("call `mount` immediately", function()
	local mockMount = jest.fn()

	local mockRenderer: Renderer = {
		mount = mockMount,
	}

	render(mockRenderer, container, element)

	expect(mockMount).toHaveBeenCalledTimes(1)
end)

test("returns a function to trigger a re-render", function()
	local mockMount = jest.fn()
	mockMount.mockReturnValue = Instance.new("ScreenGui")

	local mockRenderer: Renderer = {
		mount = mockMount,
	}

	local lifecycle = render(mockRenderer, container, element)

	expect(mockMount).toHaveBeenCalledTimes(1)

	lifecycle.update()

	expect(mockMount).toHaveBeenCalledTimes(2)
end)

test("current context and prev context are passed to shouldUpdate", function()
	local context, prevContext

	local mockRenderer: Renderer = {
		mount = function() end,
		shouldUpdate = function(_context, _prevContext)
			context = _context
			prevContext = _prevContext
			return true
		end,
	}

	local lifecycle = render(mockRenderer, container, element)

	expect(context).toBeDefined()
	expect(prevContext).toBeNil()

	lifecycle.update()

	expect(context).toBeDefined()
	expect(prevContext).toBeDefined()
end)

test("context is passed to shouldUpdate", function()
	local context

	local args = {
		foo = true,
	}

	local mockRenderer: Renderer = {
		shouldUpdate = function(_context)
			context = _context
		end,
		mount = function() end,
	}

	render(mockRenderer, container, element, args)

	expect(context).toEqual({
		container = container,
		args = args,
	})
end)

test("only rerender if shouldUpdate returns true", function()
	local mockMount = jest.fn()
	local mockShouldUpdate = jest.fn().mockReturnValue(true)

	local mockRenderer: Renderer = {
		shouldUpdate = mockShouldUpdate,
		mount = mockMount,
	}

	local lifecycle = render(mockRenderer, container, {})

	expect(mockMount).toHaveBeenCalledTimes(1)

	lifecycle.update()

	expect(mockMount).toHaveBeenCalledTimes(2)

	mockShouldUpdate.mockReturnValue(false)
	lifecycle.update()

	expect(mockMount).toHaveBeenCalledTimes(2)
end)

test("destroy all children of the container when rerendering if shouldUpdate is true", function()
	local mockShouldUpdate = jest.fn().mockReturnValue(true)

	local mockRenderer: Renderer = {
		mount = function(container, element)
			element.Parent = container
		end,
		shouldUpdate = mockShouldUpdate,
	}

	local element = Instance.new("Folder")
	local lifecycle = render(mockRenderer, container, element)

	expect(#container:GetChildren()).toBe(1)

	lifecycle.unmount()

	expect(#container:GetChildren()).toBe(0)
end)

test("prevContext is nil on the first render", function()
	local renders = 0

	local mockShouldUpdate = jest.fn().mockImplementation(function()
		return true
	end)

	local mockRenderer: Renderer = {
		shouldUpdate = mockShouldUpdate,
		mount = function()
			renders += 1
			return Instance.new("Folder")
		end,
	}

	local lifecycle = render(mockRenderer, container, element)

	local context = mockShouldUpdate.mock.lastCall[1]
	expect(context).toBeDefined()
	--[[
		Jest is sending back the second arg as a Symbol representing nil, which
		doesn't match with toBeNil. There needs to be an upstream change before
		we can use the commented expect() call.
	]]
	-- expect(mockShouldUpdate.mock.lastCall[2]).toBeNil()
	expect(tostring(mockShouldUpdate.mock.lastCall[2])).toEqual("Symbol($$nil)")

	lifecycle.update()

	expect(mockShouldUpdate.mock.lastCall[1]).toBeDefined()
	expect(mockShouldUpdate.mock.lastCall[2]).toEqual(context)
end)
