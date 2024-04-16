local flipbook = script:FindFirstAncestor("flipbook")

local JestGlobals = require(flipbook.Packages.JestGlobals)
local types = require(flipbook.Renderers.types)
local render = require(script.Parent.render)

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

type Renderer = types.Renderer

local target: Instance
local element = jest.fn()

beforeEach(function()
	target = Instance.new("Folder")
end)

afterEach(function()
	target:Destroy()
	jest.resetAllMocks()
end)

test("call `mount` immediately", function()
	local mockMount = jest.fn()

	local mockRenderer: Renderer = {
		mount = mockMount,
	}

	render(mockRenderer, target, element)

	expect(mockMount).toHaveBeenCalledTimes(1)
end)

test("returns a function to trigger a re-render", function()
	local mockMount = jest.fn()
	mockMount.mockReturnValue = Instance.new("ScreenGui")

	local mockRenderer: Renderer = {
		mount = mockMount,
	}

	local update = render(mockRenderer)

	expect(mockMount).toHaveBeenCalledTimes(1)

	update()

	expect(mockMount).toHaveBeenCalledTimes(2)
end)

test("current context and prev context are passed to shouldUpdate", function()
	local context, prevContext

	local mockRenderer: Renderer = {
		shouldUpdate = function(_context, _prevContext)
			context = _context
			prevContext = _prevContext
			return true
		end,
	}

	local update = render(mockRenderer, target, element)
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
	}

	render(mockRenderer, target, element, args)

	expect(context).toEqual({
		target = target,
		element = element,
		args = args,
	})
end)

test("only render if shouldUpdate returns true", function()
	local mockMount = jest.fn()

	local mockRenderer: Renderer = {
		shouldUpdate = function()
			return false
		end,
		mount = mockMount,
	}

	local update = render(mockRenderer)

	expect(mockMount).never.toHaveBeenCalled()

	update()

	expect(mockMount).never.toHaveBeenCalled()
end)

test("if unmount is not specified, implicitly destroy the handle", function()
	local mockDestroy = jest.fn()

	local mockRenderer: Renderer = {
		mount = function()
			local mockInstance = {
				Destroy = mockDestroy,
			}
			return mockInstance
		end,
	}

	local update = render(mockRenderer)

	expect(mockDestroy).never.toHaveBeenCalled()

	update()

	expect(mockDestroy).toHaveBeenCalled()
end)
