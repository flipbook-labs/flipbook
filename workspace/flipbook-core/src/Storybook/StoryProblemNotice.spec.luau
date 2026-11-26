local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryProblemNotice = require("./StoryProblemNotice")

local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local MESSAGE = "ReplicatedStorage.Components.Button:12: attempt to index nil with 'Padding'"

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

local function renderedText(): { string }
	local texts = {}
	for _, descendant in container:GetDescendants() do
		if descendant:IsA("TextLabel") then
			table.insert(texts, descendant.Text)
		end
	end
	return texts
end

test("shows the error's message without the traceback after it", function()
	act(function()
		root:render(React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			Notice = React.createElement(StoryProblemNotice, {
				problem = `{MESSAGE}\nReplicatedStorage.Packages.ModuleLoader:162 function require`,
			}),
		}))
	end)

	local texts = renderedText()
	expect(texts).toContain(MESSAGE)
	for _, text in texts do
		expect(text).never.toMatch("ModuleLoader")
	end
end)
