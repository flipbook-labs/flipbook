local Fusion = require("@pkg/Fusion")
local JestGlobals = require("@pkg/JestGlobals")

local createFusionRenderer = require("./createFusionRenderer")
local render = require("./render")

local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local New = Fusion.New
type StateObject<T> = Fusion.StateObject<T>

local function Button(props: {
	isDisabled: StateObject<boolean>,
})
	return New("TextButton")({
		Text = if props.isDisabled and props.isDisabled:get() then "Disabled" else "Enabled",
	})
end

local container
local renderer

beforeEach(function()
	container = Instance.new("Folder")

	renderer = createFusionRenderer({
		Fusion = Fusion,
	})
end)

test("render a Fusion component", function()
	render(renderer, container, Button)
	expect(container:FindFirstChildWhichIsA("TextButton")).toBeDefined()
end)

test("unmount a Fusion component", function()
	local lifecycle = render(renderer, container, Button)

	expect(#container:GetChildren()).toBe(1)

	lifecycle.unmount()

	expect(#container:GetChildren()).toBe(0)
end)

test("args are transformed into Values", function()
	render(renderer, container, Button, {
		isDisabled = true,
	})

	local element = container:FindFirstChildWhichIsA("TextButton")
	assert(element, "no element found")
	expect(element.Text).toBe("Disabled")
end)

test("update the component on arg changes", function()
	expect(#container:GetChildren()).toBe(0)

	local lifecycle = render(renderer, container, Button, {
		isDisabled = true,
	})

	expect(#container:GetChildren()).toBe(1)

	local element = container:FindFirstChildWhichIsA("TextButton")
	assert(element, "no element found")
	expect(element.Text).toBe("Disabled")

	lifecycle.update({
		isDisabled = false,
	})

	expect(#container:GetChildren()).toBe(1)
	expect(element.Text).toBe("Enabled")
end)
