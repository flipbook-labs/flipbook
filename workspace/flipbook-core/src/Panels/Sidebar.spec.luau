local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local Sidebar = require("./Sidebar")

local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local TEST_ID = "sidebar-spec"

local container: Folder
local root: ReactRoblox.RootType

beforeEach(function()
	container = Instance.new("Folder")
	container.Parent = CoreGui
	root = ReactRoblox.createRoot(container)
end)

afterEach(function()
	act(function()
		root:unmount()
	end)
	container:Destroy()
end)

local function renderTopPadding(topbarInset: Rect?): number
	act(function()
		root:render(React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			Sidebar = React.createElement(Sidebar, {
				topbarInset = topbarInset,
				testId = TEST_ID,
			}),
		}))
	end)

	for _, descendant in container:GetDescendants() do
		if descendant:IsA("GuiObject") and descendant:HasTag(`data-testid={TEST_ID}`) then
			local padding = descendant:FindFirstChildWhichIsA("UIPadding")
			return if padding then padding.PaddingTop.Offset else 0
		end
	end

	error("Sidebar did not render")
end

test("has no top padding without a topbar inset", function()
	expect(renderTopPadding(nil)).toBe(0)
end)

test("pads its top so the search field starts below the topbar inset", function()
	local topbarInset = Rect.new(Vector2.new(120, 14), Vector2.new(900, 72))

	expect(renderTopPadding(topbarInset)).toBe(72)
end)

test("ignores a topbar inset that ends above the sidebar", function()
	local topbarInset = Rect.new(Vector2.new(120, -58), Vector2.new(900, -4))

	expect(renderTopPadding(topbarInset)).toBe(0)
end)
