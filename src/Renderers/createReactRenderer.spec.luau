local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local createReactRenderer = require("./createReactRenderer")
local render = require("./render")

local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local target
local renderer

local function Button(props: { isDisabled: boolean? })
	return React.createElement("TextButton", {
		Text = if props.isDisabled then "Disabled" else "Enabled",
	})
end

beforeEach(function()
	target = Instance.new("Folder")

	renderer = createReactRenderer({
		React = React,
		ReactRoblox = ReactRoblox,
	})
end)

test("render a React componnet", function()
	local element = renderer.mount(target, Button)

	expect(element).toBeDefined()
	expect(typeof(element)).toBe("Instance")
	assert(element:IsA("TextButton"), "not a TextButton")
	expect(element.Text).toBe("Enabled")
end)

test("unmount a React component", function() end)

test("pass args as props", function()
	local element = renderer.mount(target, Button)

	render(renderer, target, element, {
		isDisabled = true,
	})

	local button = target:FindFirstChildWhichIsA("TextButton")

	expect(button).toBeDefined()
	expect(button.Text).toBe("Disabled")
end)

test("update the component on arg changes", function()
	local element = renderer.mount(target, Button)

	local update = render(renderer, target, element, {
		isDisabled = true,
	})

	local button = target:FindFirstChildWhichIsA("TextButton")

	expect(button).toBeDefined()
	expect(button.Text).toBe("Disabled")

	update({
		isDisabled = false,
	})

	expect(button.Text).toBe("Enabled")
end)

test("never re-mount on arg changes", function() end)

test("portals", function() end)
