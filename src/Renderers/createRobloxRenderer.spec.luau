local JestGlobals = require("@pkg/JestGlobals")

local createRobloxRenderer = require("./createRobloxRenderer")
local render = require("./render")

local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local function Button(args: { isDisabled: boolean? })
	local button = Instance.new("TextButton")
	button.Text = if args.isDisabled then "Disabled" else "Enabled"

	return button
end

local container
local renderer

beforeEach(function()
	container = Instance.new("Folder")
	renderer = createRobloxRenderer()
end)

test("render a GuiObject", function()
	render(renderer, container, Instance.new("TextLabel"))

	local element = container:GetChildren()[1]

	assert(element, "no element found")
	expect(typeof(element)).toBe("Instance")
	assert(element:IsA("TextLabel"), "not a TextButton")
end)

test("render a GuiObject with args", function()
	render(renderer, container, Button, {
		isDisabled = true,
	})

	local element = container:FindFirstChildWhichIsA("TextButton")
	assert(element, "no element found")
	expect(element.Text).toBe("Disabled")
end)

test("update the GuiObject on arg changes", function()
	local lifecycle = render(renderer, container, Button, {
		isDisabled = true,
	})

	local button = container:FindFirstChildWhichIsA("TextButton")

	expect(button).toBeDefined()
	expect(button.Text).toBe("Disabled")

	lifecycle.update({
		isDisabled = false,
	})

	button = container:FindFirstChildWhichIsA("TextButton")

	expect(button.Text).toBe("Enabled")
end)

test("lifecycle", function()
	expect(#container:GetChildren()).toBe(0)

	local lifecycle = render(renderer, container, Button, {
		args = {
			isDisabled = false,
		},
	})

	expect(#container:GetChildren()).toBe(1)

	local element = container:FindFirstChildWhichIsA("TextButton")
	assert(element, "no TextButton found")
	expect(element.Text).toBe("Enabled")

	lifecycle.update({
		isDisabled = true,
	})

	expect(#container:GetChildren()).toBe(1)

	local prevElement = element
	element = container:FindFirstChildWhichIsA("TextButton")
	assert(element, "no TextButton found")
	expect(element).never.toBe(prevElement)
	expect(element.Text).toBe("Disabled")

	lifecycle.unmount()

	expect(#container:GetChildren()).toBe(0)
end)
