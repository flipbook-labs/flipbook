local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local Topbar = require("./Topbar")

local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local TEST_ID = "topbar-spec"

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

local function renderTopbarHeight(topbarInset: Rect?): number
	act(function()
		root:render(React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			Topbar = React.createElement(Topbar, {
				topbarInset = topbarInset,
				testId = TEST_ID,
			}),
		}))
	end)

	for _, descendant in container:GetDescendants() do
		if descendant:IsA("GuiObject") and descendant:HasTag(`data-testid={TEST_ID}`) then
			return descendant.Size.Y.Offset
		end
	end

	error("Topbar did not render")
end

local function insetWithHeight(height: number): Rect
	return Rect.new(Vector2.new(120, height - 58), Vector2.new(900, height))
end

test("grows to fill a topbar inset taller than its usual height", function()
	expect(renderTopbarHeight(insetWithHeight(200))).toBe(200)
end)

test("keeps its usual height when the topbar inset is shorter", function()
	local usualHeight = renderTopbarHeight(nil)

	expect(renderTopbarHeight(insetWithHeight(10))).toBe(usualHeight)
end)
