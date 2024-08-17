local JestGlobals = require("@pkg/JestGlobals")
local Roact = require("@pkg/Roact")
local createRoactRenderer = require("./createRoactRenderer")

local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local function Button(props: { isDisabled: boolean? })
	return Roact.createElement("TextButton", {
		Text = if props.isDisabled then "Disabled" else "Enabled",
	})
end

local ButtonClassComponent = Roact.Component:extend("ButtonClassComponent")

function ButtonClassComponent:render()
	return Roact.createElement("TextButton", {
		Text = if self.props.isDisabled then "Disabled" else "Enabled",
	})
end

local container
local renderer

beforeEach(function()
	container = Instance.new("Folder")

	renderer = createRoactRenderer({
		Roact = Roact,
	})
end)

test("render a functional componnet", function()
	renderer.mount(container, Button)

	local element = container:GetChildren()[1]

	assert(element, "no element found")
	expect(typeof(element)).toBe("Instance")
	assert(element:IsA("TextButton"), "not a TextButton")
	expect(element.Text).toBe("Enabled")
end)

test("render a class component", function()
	renderer.mount(container, ButtonClassComponent)

	local element = container:GetChildren()[1]

	assert(element, "no element found")
	expect(typeof(element)).toBe("Instance")
	assert(element:IsA("TextButton"), "not a TextButton")
	expect(element.Text).toBe("Enabled")
end)

test("lifecycle", function()
	expect(#container:GetChildren()).toBe(0)

	renderer.mount(container, Button, {
		args = {
			isDisabled = false,
		},
	})

	expect(#container:GetChildren()).toBe(1)

	local element = container:FindFirstChildWhichIsA("TextButton")
	assert(element, "no TextButton found")
	expect(element.Text).toBe("Enabled")

	renderer.update({
		args = {
			isDisabled = true,
		},
	})

	expect(#container:GetChildren()).toBe(1)

	local prevElement = element
	element = container:FindFirstChildWhichIsA("TextButton")
	assert(element, "no TextButton found")
	expect(element).toBe(prevElement)
	expect(element.Text).toBe("Disabled")

	renderer.unmount()

	expect(#container:GetChildren()).toBe(0)
end)

test("pass args as props", function()
	renderer.mount(container, Button, {
		args = {
			isDisabled = true,
		},
	})

	local button = container:FindFirstChildWhichIsA("TextButton")

	expect(button).toBeDefined()
	expect(button.Text).toBe("Disabled")
end)

test("update the component on arg changes", function()
	renderer.mount(container, Button, {
		args = {
			isDisabled = true,
		},
	})

	local button = container:FindFirstChildWhichIsA("TextButton")

	expect(button).toBeDefined()
	expect(button.Text).toBe("Disabled")

	renderer.update({
		isDisabled = false,
	})

	expect(button.Text).toBe("Enabled")
end)
