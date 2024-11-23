local JestGlobals = require("@pkg/jest-globals")
local React = require("@pkg/react")
local ReactRoblox = require("@pkg/react-roblox")
local useEvent = require("@root/Common/useEvent")
local useZoom = require("./useZoom")

local expect = JestGlobals.expect
local test = JestGlobals.test
local afterEach = JestGlobals.afterEach

local container = Instance.new("ScreenGui")
local root = ReactRoblox.createRoot(container)

local story = Instance.new("ModuleScript")
local zoomIn = Instance.new("BindableEvent")
local zoomOut = Instance.new("BindableEvent")

local function HookTester(props: { story: ModuleScript })
	local zoom = useZoom(props.story)

	useEvent(zoomIn.Event, function()
		zoom.zoomIn()
	end)

	useEvent(zoomOut.Event, function()
		zoom.zoomOut()
	end)

	return React.createElement("TextLabel", {
		Text = zoom.value,
	})
end

afterEach(function()
	ReactRoblox.act(function()
		root:unmount()
	end)
end)

test("be set to 0 zoom by default", function()
	local element = React.createElement(HookTester, {
		story = story,
	})

	ReactRoblox.act(function()
		root:render(element)
	end)

	local result = container:FindFirstChildWhichIsA("TextLabel") :: TextLabel

	expect(tonumber(result.Text)).toBe(0)
end)

test("zoom in", function()
	local element = React.createElement(HookTester, {
		story = story,
	})

	ReactRoblox.act(function()
		root:render(element)
	end)

	local result = container:FindFirstChildWhichIsA("TextLabel") :: TextLabel

	ReactRoblox.act(function()
		zoomIn:Fire()
	end)

	expect(tonumber(result.Text)).toBe(0.25)
end)

test("zoom out", function()
	local element = React.createElement(HookTester, {
		story = story,
	})

	ReactRoblox.act(function()
		root:render(element)
	end)

	local result = container:FindFirstChildWhichIsA("TextLabel") :: TextLabel

	ReactRoblox.act(function()
		zoomOut:Fire()
	end)

	expect(tonumber(result.Text)).toBe(-0.25)
end)

test("reset the zoom any time the story changes", function()
	local element = React.createElement(HookTester, {
		story = story,
	})

	ReactRoblox.act(function()
		root:render(element)
	end)

	local result = container:FindFirstChildWhichIsA("TextLabel") :: TextLabel

	ReactRoblox.act(function()
		zoomIn:Fire()
	end)

	expect(tonumber(result.Text)).toBe(0.25)

	element = React.createElement(HookTester, {
		story = Instance.new("ModuleScript"),
	})

	ReactRoblox.act(function()
		root:render(element)
	end)

	result = container:FindFirstChildWhichIsA("TextLabel") :: TextLabel

	expect(tonumber(result.Text)).toBe(0)
end)
