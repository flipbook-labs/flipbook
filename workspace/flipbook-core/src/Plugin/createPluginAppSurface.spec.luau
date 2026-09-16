local JestGlobals = require("@pkg/JestGlobals")

local createPluginAppSurface = require("@root/Plugin/createPluginAppSurface")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local screenParent: Folder
local widget: ScreenGui

beforeEach(function()
	screenParent = Instance.new("Folder")
	widget = Instance.new("ScreenGui")
	widget.Enabled = false
end)

afterEach(function()
	screenParent:Destroy()
	widget:Destroy()
end)

test("moves one app container between the widget and viewport", function()
	local surface = createPluginAppSurface(widget :: any, screenParent)
	local screenGui = screenParent:FindFirstChild("FlipbookViewport") :: ScreenGui

	expect(surface.container.Parent).toBe(widget)
	expect(surface.getName()).toBe("widget")
	expect(surface.isVisible()).toBe(false)

	surface.openViewport()
	expect(surface.container.Parent).toBe(screenGui)
	expect(surface.getName()).toBe("viewport")
	expect(surface.isVisible()).toBe(true)
	expect(widget.Enabled).toBe(false)

	surface.openWidget()
	expect(surface.container.Parent).toBe(widget)
	expect(surface.getName()).toBe("widget")
	expect(surface.isVisible()).toBe(true)
	expect(widget.Enabled).toBe(true)

	surface.destroy()
	expect(screenParent:FindFirstChild("FlipbookViewport")).toBeNil()
end)

test("returns to the widget when Studio enables it directly", function()
	local surface = createPluginAppSurface(widget :: any, screenParent)
	surface.openViewport()

	widget.Enabled = true

	expect(surface.container.Parent).toBe(widget)
	expect(surface.getName()).toBe("widget")
	expect(surface.isVisible()).toBe(true)
end)
