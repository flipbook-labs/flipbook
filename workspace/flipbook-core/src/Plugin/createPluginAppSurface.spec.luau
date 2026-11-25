local JestGlobals = require("@pkg/JestGlobals")

local createPluginAppSurface = require("./createPluginAppSurface")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

type PluginAppSurface = createPluginAppSurface.PluginAppSurface

local screenParent: Folder
local surface: PluginAppSurface
local visibilityChanges: { boolean }
local widget: DockWidgetPluginGui

beforeEach(function()
	screenParent = Instance.new("Folder")
	visibilityChanges = {}

	-- Only Studio can create a DockWidgetPluginGui. A ScreenGui has the same
	-- Enabled property.
	widget = (Instance.new("ScreenGui") :: Instance) :: DockWidgetPluginGui
	widget.Enabled = false

	surface = createPluginAppSurface(widget, screenParent, function(isVisible)
		table.insert(visibilityChanges, isVisible)
	end)
end)

local function getViewportGui(): ScreenGui
	return screenParent:FindFirstChild("FlipbookViewport") :: ScreenGui
end

local function setWidgetOpen(isOpen: boolean)
	widget.Enabled = isOpen
	-- Roblox can defer signals, so this gives the surface time to see the change.
	task.wait()
end

afterEach(function()
	surface.destroy()
	screenParent:Destroy()
	widget:Destroy()
end)

test("starts in the hidden widget", function()
	expect(surface.container.Parent).toBe(widget)
	expect(surface.getName()).toBe("widget")
	expect(surface.isVisible()).toBe(false)
	expect(getViewportGui().Archivable).toBe(false)
end)

test("moves one container between the viewport and the widget", function()
	local container = surface.container

	surface.openViewport()
	expect(container.Parent).toBe(getViewportGui())
	expect(surface.getName()).toBe("viewport")
	expect(surface.isVisible()).toBe(true)
	expect(widget.Enabled).toBe(false)

	surface.openWidget()
	expect(container.Parent).toBe(widget)
	expect(surface.getName()).toBe("widget")
	expect(surface.isVisible()).toBe(true)
	expect(getViewportGui().Enabled).toBe(false)
end)

test("returns to the widget when Studio enables it directly", function()
	surface.openViewport()
	task.wait()

	setWidgetOpen(true)

	expect(surface.container.Parent).toBe(widget)
	expect(surface.getName()).toBe("widget")
	expect(surface.isVisible()).toBe(true)
end)

test("reports the app opening and closing, but not moving", function()
	surface.openViewport()
	task.wait()
	surface.openWidget()
	task.wait()
	expect(visibilityChanges).toEqual({ true })

	setWidgetOpen(false)
	expect(visibilityChanges).toEqual({ true, false })
end)

test("removes its instances when destroyed", function()
	surface.destroy()

	expect(getViewportGui()).toBeNil()
	expect(widget:GetChildren()).toEqual({})
end)
