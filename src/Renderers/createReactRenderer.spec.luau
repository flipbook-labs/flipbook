local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local createReactRenderer = require("./createReactRenderer")
local render = require("./render")

local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local act = ReactRoblox.act

local function Button(props: { isDisabled: boolean? })
	return React.createElement("TextButton", {
		Text = if props.isDisabled then "Disabled" else "Enabled",
	})
end

local ButtonClassComponent = React.Component:extend("ButtonClassComponent")

function ButtonClassComponent:render()
	return React.createElement("TextButton", {
		Text = if self.props.isDisabled then "Disabled" else "Enabled",
	})
end

local container
local renderer

beforeEach(function()
	container = Instance.new("Folder")

	renderer = createReactRenderer({
		React = React,
		ReactRoblox = ReactRoblox,
	})
end)

test("render a functional componnet", function()
	render(renderer, container, Button)

	act(function()
		task.wait()
	end)

	local element = container:GetChildren()[1]

	assert(element, "no element found")
	expect(typeof(element)).toBe("Instance")
	assert(element:IsA("TextButton"), "not a TextButton")
	expect(element.Text).toBe("Enabled")
end)

test("render a class component", function()
	render(renderer, container, ButtonClassComponent)

	act(function()
		task.wait()
	end)

	local element = container:GetChildren()[1]

	assert(element, "no element found")
	expect(typeof(element)).toBe("Instance")
	assert(element:IsA("TextButton"), "not a TextButton")
	expect(element.Text).toBe("Enabled")
end)

test("pass args as props", function()
	render(renderer, container, Button, {
		isDisabled = true,
	})

	act(function()
		task.wait()
	end)

	local button = container:FindFirstChildWhichIsA("TextButton")

	expect(button).toBeDefined()
	expect(button.Text).toBe("Disabled")
end)

test("update the component on arg changes", function()
	local lifecycle = render(renderer, container, Button, {
		isDisabled = true,
	})

	act(function()
		task.wait()
	end)

	local button = container:FindFirstChildWhichIsA("TextButton")

	expect(button).toBeDefined()
	expect(button.Text).toBe("Disabled")

	lifecycle.update({
		isDisabled = false,
	})

	act(function()
		task.wait()
	end)

	expect(button.Text).toBe("Enabled")
end)

test("lifecycle", function()
	expect(#container:GetChildren()).toBe(0)

	local lifecycle = render(renderer, container, Button, {
		isDisabled = false,
	})

	act(function()
		task.wait()
	end)

	expect(#container:GetChildren()).toBe(1)

	local element = container:FindFirstChildWhichIsA("TextButton")
	assert(element, "no TextButton found")
	expect(element.Text).toBe("Enabled")

	lifecycle.update({
		isDisabled = true,
	})

	act(function()
		task.wait()
	end)

	expect(#container:GetChildren()).toBe(1)

	local prevElement = element
	element = container:FindFirstChildWhichIsA("TextButton")
	assert(element, "no TextButton found")
	expect(element).toBe(prevElement)
	expect(element.Text).toBe("Disabled")

	lifecycle.unmount()

	act(function()
		task.wait()
	end)

	expect(#container:GetChildren()).toBe(0)
end)
