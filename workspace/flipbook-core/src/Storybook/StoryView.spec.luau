local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local AppMode = require("@root/Enums/AppMode")
local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryView = require("./StoryView")
local createFlipbookStore = require("@root/FlipbookStore/createFlipbookStore")
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local act = ReactRoblox.act
local e = React.createElement

--[[
	Storyteller loads Story modules asynchronously, and after an edit it waits
	for a short quiet period (0.3 seconds) before it reloads. The test polls
	for each expected change instead of waiting a fixed time. The timeout is
	well past the quiet period, and if it passes, the `expect` after the poll
	reports the failure.
]]
local POLL_INTERVAL_SECONDS = 0.1
local POLL_TIMEOUT_SECONDS = 3

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

-- Each version counts how many times the module has run in its `Evaluations`
-- attribute, so the test can tell whether Storyteller loaded it again.
local function createStorySource(frameName: string): string
	return string.format(
		[[
script:SetAttribute("Evaluations", (script:GetAttribute("Evaluations") or 0) + 1)

return {
	story = function(storyContainer, _props)
		local frame = Instance.new("Frame")
		frame.Name = "%s"
		frame.Parent = storyContainer
		return function()
			frame:Destroy()
		end
	end,
}
]],
		frameName
	)
end

local function findNotice(): TextLabel?
	for _, descendant in container:GetDescendants() do
		if descendant:IsA("TextLabel") and descendant.Text:find("latest edit has an error", 1, true) then
			return descendant
		end
	end
	return nil
end

local function waitUntil(predicate: () -> boolean)
	local elapsed = 0
	while not predicate() and elapsed < POLL_TIMEOUT_SECONDS do
		act(function()
			task.wait(POLL_INTERVAL_SECONDS)
		end)
		elapsed += POLL_INTERVAL_SECONDS
	end
end

local function renderStory(storyModule: ModuleScript)
	local plugin = MockPlugin.new()
	local store = createFlipbookStore({
		mode = AppMode.PluginWidget,
		plugin = plugin,
	})
	store.story.openStory(storyModule, createLoadedStorybook())

	act(function()
		root:render(e(ContextProviders, {
			plugin = plugin,
			store = store,
		}, {
			StoryView = e(StoryView),
		}))
	end)
end

test("keeps the last working Story and shows the error when an edit fails to load", function()
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = "Live.story"
	storyModule.Source = createStorySource("FirstVersion")
	storyModule.Parent = container

	renderStory(storyModule)
	waitUntil(function()
		return container:FindFirstChild("FirstVersion", true) ~= nil
	end)
	expect(container:FindFirstChild("FirstVersion", true)).toBeDefined()
	expect(findNotice()).toBeUndefined()

	storyModule.Source = "return {"
	waitUntil(function()
		return findNotice() ~= nil
	end)
	expect(findNotice()).toBeDefined()
	expect(container:FindFirstChild("FirstVersion", true)).toBeDefined()
	-- The last working version stayed loaded, rather than the module running again.
	expect(storyModule:GetAttribute("Evaluations")).toBe(1)

	storyModule.Source = createStorySource("SecondVersion")
	waitUntil(function()
		return container:FindFirstChild("SecondVersion", true) ~= nil
	end)
	expect(container:FindFirstChild("SecondVersion", true)).toBeDefined()
	expect(findNotice()).toBeUndefined()
end)
