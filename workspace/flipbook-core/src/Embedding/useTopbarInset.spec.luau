local JestGlobals = require("@pkg/JestGlobals")
local ReactRoblox = require("@pkg/ReactRoblox")

local renderHook = require("@root/Testing/renderHook")
local useTopbarInset = require("./useTopbarInset")

local act = ReactRoblox.act
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

type TopbarSource = useTopbarInset.TopbarSource

local GUI_INSET = Vector2.new(0, 58)

local topbarInset: Rect
local onTopbarInsetChanged: (() -> ())?
local source: TopbarSource

beforeEach(function()
	topbarInset = Rect.new(Vector2.new(120, 0), Vector2.new(900, 58))
	onTopbarInsetChanged = nil
	source = {
		getTopbarInset = function()
			return topbarInset
		end,
		subscribe = function(onChange)
			onTopbarInsetChanged = onChange
			return function()
				onTopbarInsetChanged = nil
			end
		end,
		getGuiInset = function()
			return GUI_INSET
		end,
	}
end)

local function renderInset()
	return renderHook(function()
		return useTopbarInset({ current = nil }, source)
	end)
end

test("starts from the current topbar inset", function()
	local getInset = renderInset()

	expect(getInset().Min).toEqual(Vector2.new(120, -58))
	expect(getInset().Max).toEqual(Vector2.new(900, 0))
end)

test("updates when the topbar inset changes", function()
	local getInset = renderInset()

	act(function()
		topbarInset = Rect.new(Vector2.new(160, 0), Vector2.new(900, 72))
		assert(onTopbarInsetChanged, "useTopbarInset did not subscribe to topbar changes")
		onTopbarInsetChanged()
	end)

	expect(getInset().Min).toEqual(Vector2.new(160, -58))
	expect(getInset().Max).toEqual(Vector2.new(900, 14))
end)
