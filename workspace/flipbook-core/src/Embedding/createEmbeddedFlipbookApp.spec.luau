local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local ReactRoblox = require("@pkg/ReactRoblox")

local createEmbeddedFlipbookApp = require("./createEmbeddedFlipbookApp")
local getInstancePath = require("@root/Common/getInstancePath")

local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local GATEWAY_NAME = "FlipbookAgentGateway"

local container: Folder
local screenGui: ScreenGui
local story: ModuleScript
local app: typeof(createEmbeddedFlipbookApp(Instance.new("ScreenGui")))?

beforeEach(function()
	container = Instance.new("Folder")
	container.Parent = CoreGui

	screenGui = Instance.new("ScreenGui")
	screenGui.Parent = container

	story = Instance.new("ModuleScript")
	story.Name = "EmbeddedGateway.story"
	story.Source = "return { story = function() end }"
	story.Parent = ReplicatedStorage

	app = nil
end)

local function mountApp()
	act(function()
		app = createEmbeddedFlipbookApp(screenGui)
	end)
end

local function destroyApp()
	if app == nil then
		return
	end

	local mountedApp = app
	app = nil
	act(function()
		mountedApp.destroy()
	end)
end

afterEach(function()
	destroyApp()
	story:Destroy()
	container:Destroy()
end)

local function getGateway(): BindableFunction
	local gateway = container:FindFirstChild(GATEWAY_NAME)
	assert(gateway and gateway:IsA("BindableFunction"), `{GATEWAY_NAME} was not published beside the ScreenGui`)
	return gateway
end

test("routes gateway actions to the mounted app", function()
	mountApp()

	local response = getGateway():Invoke({
		method = "call",
		action = "listStories",
		params = {},
	})

	expect(response.ok).toBe(true)
	expect(response.result.stories).toContainEqual(expect.objectContaining({
		name = "EmbeddedGateway",
		path = getInstancePath(story),
	}))
end)

test("removes the gateway and unmounts the app when destroyed", function()
	mountApp()

	expect(container:FindFirstChild(GATEWAY_NAME)).never.toBeNil()
	expect(#screenGui:GetChildren()).toBeGreaterThan(0)

	destroyApp()

	expect(container:FindFirstChild(GATEWAY_NAME)).toBeNil()
	expect(#screenGui:GetChildren()).toBe(0)
end)

test("throws when the ScreenGui has no parent", function()
	screenGui.Parent = nil

	expect(function()
		createEmbeddedFlipbookApp(screenGui)
	end).toThrow("embedded ScreenGui must be parented")
end)
