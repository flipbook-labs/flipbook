local CoreGui = game:GetService("CoreGui")

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

-- Roblox lays out GUI between frames, so a moved Frame's AbsolutePosition
-- changes after a short wait rather than right away.
local function waitFor(condition: () -> boolean)
	local deadline = os.clock() + 2
	while not condition() and os.clock() < deadline do
		task.wait()
	end
end

test("follows the container as it moves", function()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = CoreGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(100, 100)
	frame.Parent = screenGui

	local containerRef = { current = frame }
	local getInset = renderHook(function()
		return useTopbarInset(containerRef, source)
	end)

	act(function()
		frame.Position = UDim2.fromOffset(40, 30)
		waitFor(function()
			return frame.AbsolutePosition == Vector2.new(40, 30)
		end)
		-- Let the AbsolutePosition change signal reach the hook.
		task.wait()
	end)

	expect(frame.AbsolutePosition).toEqual(Vector2.new(40, 30))
	expect(getInset().Min).toEqual(Vector2.new(80, -88))
	expect(getInset().Max).toEqual(Vector2.new(860, -30))

	screenGui:Destroy()
end)
