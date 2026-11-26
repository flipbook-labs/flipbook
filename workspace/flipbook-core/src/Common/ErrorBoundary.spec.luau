local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ErrorBoundary = require("./ErrorBoundary")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local act = ReactRoblox.act
local e = React.createElement

local container: Folder
local root: ReactRoblox.RootType

beforeEach(function()
	container = Instance.new("Folder")
	root = ReactRoblox.createRoot(container)
end)

afterEach(function()
	act(function()
		root:unmount()
	end)
end)

local function Fallback(problem: string, reset: () -> ())
	return e("TextButton", {
		Text = problem,
		[React.Event.Activated] = reset,
	})
end

local function ThrowsWhileRendering(): React.Node
	error("render failed")
end

local function ThrowsInEffect()
	React.useEffect(function()
		error("effect failed")
	end, {})

	return e("Frame")
end

local function render(children: React.Node, resetKey: unknown?)
	act(function()
		root:render(e("Folder", {}, {
			Sibling = e("Frame"),
			Boundary = e(ErrorBoundary, {
				fallback = Fallback,
				resetKey = resetKey,
			}, children),
		}))
	end)
end

local function getFallback(): TextButton?
	return container:FindFirstChildWhichIsA("TextButton", true)
end

test("shows the fallback when a child throws while rendering", function()
	render(e(ThrowsWhileRendering))

	local fallback = getFallback()
	assert(fallback, "expected the fallback to render")
	expect(fallback.Text).toMatch("render failed")
	expect(container:FindFirstChild("Sibling", true)).toBeDefined()
end)

test("shows the fallback when a child throws in an effect", function()
	render(e(ThrowsInEffect))

	local fallback = getFallback()
	assert(fallback, "expected the fallback to render")
	expect(fallback.Text).toMatch("effect failed")
	expect(container:FindFirstChild("Sibling", true)).toBeDefined()
end)

test("renders its children again when the reset key changes", function()
	render(e(ThrowsWhileRendering), "first")
	expect(getFallback()).toBeDefined()

	render(e("Frame", { Name = "Recovered" }), "second")

	expect(getFallback()).toBeUndefined()
	expect(container:FindFirstChild("Recovered", true)).toBeDefined()
end)

test("keeps the fallback while the reset key stays the same", function()
	render(e(ThrowsWhileRendering), "same")
	render(e("Frame", { Name = "Recovered" }), "same")

	expect(getFallback()).toBeDefined()
	expect(container:FindFirstChild("Recovered", true)).toBeUndefined()
end)
