local Fusion = require("@pkg/Fusion")
local JestGlobals = require("@pkg/JestGlobals")
local createFusionRenderer = require("./createFusionRenderer")

local expect = JestGlobals.expect
local test = JestGlobals.test

local New = Fusion.New
local Value = Fusion.Value
type StateObject<T> = Fusion.StateObject<T>

type ButtonProps = {
	isDisabled: StateObject<boolean>,
}
local function Button(props)
	return New("TextButton")({
		Text = if props.isDisabled:get() then "Disabled" else "Enabled",
	})
end

test("render a Fusion component", function()
	local renderer = createFusionRenderer({ Fusion = Fusion })
	local args = {
		isDisabled = Value(false),
	}

	local target = Instance.new("Folder")
	local gui = renderer.mount(target, Button, args)

	expect(gui).to.be.ok()
	expect(gui.Text).to.equal("Enabled")
end)

test("unmount a Fusion component", function()
	local renderer = createFusionRenderer({ Fusion = Fusion })
	local args = {
		isDisabled = Value(false),
	}

	local target = Instance.new("Folder")
	local gui = renderer.mount(target, Button, args)

	expect(gui).to.be.ok()
	expect(gui:IsDescendantOf(game)).to.equal(true)

	renderer.unmount()

	expect(gui:IsDescendantOf(game)).to.equal(false)
end)

test("update the component on arg changes", function()
	local renderer = createFusionRenderer({ Fusion = Fusion })
	local args = {
		isDisabled = Value(false),
	}

	local target = Instance.new("Folder")
	local gui = renderer.mount(target, Button, args)

	expect(gui).to.be.ok()
	expect(gui:IsDescendantOf(game)).to.equal(true)

	renderer.unmount()

	expect(gui:IsDescendantOf(game)).to.equal(false)
end)

test("never re-mount on arg changes", function() end)
