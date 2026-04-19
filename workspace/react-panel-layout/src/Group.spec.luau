local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local Group = require("@root/Group")
local Panel = require("@root/Panel")
local PanelGroupContext = require("@root/PanelGroupContext")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local act = ReactRoblox.act

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

describe("Group", function()
	test("panels register with defaultSize on mount", function()
		local contextRef = { current = nil :: any }

		local function Capture()
			contextRef.current = PanelGroupContext.use()
			return nil
		end

		act(function()
			root:render(React.createElement(Group, {
				id = "test",
				orientation = "horizontal",
			}, {
				A = React.createElement(Panel, { id = "a", LayoutOrder = 1, defaultSize = 30 }),
				B = React.createElement(Panel, { id = "b", LayoutOrder = 2, defaultSize = 70 }),
				Capture = React.createElement(Capture),
			}))
		end)

		expect(contextRef.current.sizes["a"]).toBeCloseTo(30, 1)
		expect(contextRef.current.sizes["b"]).toBeCloseTo(70, 1)
	end)

	test("defaultLayout overrides defaultSize", function()
		local contextRef = { current = nil :: any }

		local function Capture()
			contextRef.current = PanelGroupContext.use()
			return nil
		end

		act(function()
			root:render(React.createElement(Group, {
				id = "test",
				orientation = "horizontal",
				defaultLayout = { a = 40, b = 60 },
			}, {
				A = React.createElement(Panel, { id = "a", LayoutOrder = 1, defaultSize = 30 }),
				B = React.createElement(Panel, { id = "b", LayoutOrder = 2, defaultSize = 70 }),
				Capture = React.createElement(Capture),
			}))
		end)

		expect(contextRef.current.sizes["a"]).toBeCloseTo(40, 1)
		expect(contextRef.current.sizes["b"]).toBeCloseTo(60, 1)
	end)

	test("updateSizes only changes specified panels (others untouched)", function()
		local contextRef = { current = nil :: any }

		local function Capture()
			contextRef.current = PanelGroupContext.use()
			return nil
		end

		act(function()
			root:render(React.createElement(Group, {
				id = "test",
				orientation = "horizontal",
			}, {
				A = React.createElement(Panel, { id = "a", LayoutOrder = 1, defaultSize = 33 }),
				B = React.createElement(Panel, { id = "b", LayoutOrder = 2, defaultSize = 33 }),
				C = React.createElement(Panel, { id = "c", LayoutOrder = 3, defaultSize = 34 }),
				Capture = React.createElement(Capture),
			}))
		end)

		act(function()
			local sizes = table.clone(contextRef.current.sizes)
			sizes["a"] = 20
			sizes["b"] = 46
			contextRef.current.updateSizes(sizes)
		end)

		expect(contextRef.current.sizes["a"]).toBeCloseTo(20, 1)
		expect(contextRef.current.sizes["b"]).toBeCloseTo(46, 1)
		expect(contextRef.current.sizes["c"]).toBeCloseTo(34, 1)
	end)

	test("onLayoutChange fires with groupId and new sizes", function()
		local capturedId = nil
		local capturedSizes = nil

		local function onLayoutChange(id: string, sizes: { [string]: number })
			capturedId = id
			capturedSizes = sizes
		end

		local contextRef = { current = nil :: any }

		local function Capture()
			contextRef.current = PanelGroupContext.use()
			return nil
		end

		act(function()
			root:render(React.createElement(Group, {
				id = "my-group",
				orientation = "horizontal",
				onLayoutChange = onLayoutChange,
			}, {
				A = React.createElement(Panel, { id = "a", LayoutOrder = 1, defaultSize = 50 }),
				B = React.createElement(Panel, { id = "b", LayoutOrder = 2, defaultSize = 50 }),
				Capture = React.createElement(Capture),
			}))
		end)

		act(function()
			contextRef.current.updateSizes({ a = 60, b = 40 })
		end)

		expect(capturedId).toBe("my-group")
		expect(capturedSizes).toEqual({ a = 60, b = 40 })
	end)

	test("unregistered panel is removed from sizes on unmount", function()
		local contextRef = { current = nil :: any }
		local setShowPanel = nil :: any

		local function Wrapper()
			local show
			show, setShowPanel = React.useState(true)
			contextRef.current = PanelGroupContext.use()
			return if show then React.createElement(Panel, { id = "extra", LayoutOrder = 2, defaultSize = 20 }) else nil
		end

		act(function()
			root:render(React.createElement(Group, {
				id = "test",
				orientation = "horizontal",
			}, {
				A = React.createElement(Panel, { id = "a", LayoutOrder = 1, defaultSize = 80 }),
				Dynamic = React.createElement(Wrapper),
			}))
		end)

		expect(contextRef.current.sizes["extra"]).toBeDefined()

		act(function()
			setShowPanel(false)
		end)

		expect(contextRef.current.sizes["extra"]).toBeUndefined()
	end)
end)
