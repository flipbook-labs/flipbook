local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

local CommonTypes = require("@root/Common/types")
local ContextProviders = require("@root/Common/ContextProviders")
local StoryControlsContext = require("@root/StoryControls/StoryControlsContext")
local StoryPreview = require("./StoryPreview")

type LoadedStory = Storyteller.LoadedStory<unknown>
type Pluginlike = CommonTypes.Pluginlike

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local act = ReactRoblox.act
local e = React.createElement

local container: Folder
local root: ReactRoblox.RootType

local mockPlugin: Pluginlike = {
	GetSetting = function()
		return nil
	end,
	SetSetting = function() end,
} :: Pluginlike

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

local function createManualStory(name: string, story: (container: Instance, props: unknown) -> (() -> ())?): LoadedStory
	return {
		id = name,
		name = name,
		story = story,
		source = Instance.new("ModuleScript"),
		storybook = {
			name = "Storybook",
			source = Instance.new("ModuleScript"),
			storyRoots = {},
		},
	} :: LoadedStory
end

local function renderPreview(story: LoadedStory)
	act(function()
		root:render(e(ContextProviders, {
			plugin = mockPlugin,
		}, {
			App = e("Frame", {}, {
				Sibling = e("Frame"),
				Controls = e(StoryControlsContext.StoryControlsProvider, {}, {
					StoryPreview = e(StoryPreview, {
						story = story,
					}),
				}),
			}),
		}))
	end)
end

test("keeps the rest of Flipbook mounted when a Story's teardown throws", function()
	local brokenStory = createManualStory("Broken", function(storyContainer, _props)
		local frame = Instance.new("Frame")
		frame.Name = "BrokenStoryFrame"
		frame.Parent = storyContainer

		return function()
			error("teardown failed")
		end
	end)
	local nextStory = createManualStory("Next", function(storyContainer, _props)
		local frame = Instance.new("Frame")
		frame.Name = "NextStoryFrame"
		frame.Parent = storyContainer

		return nil
	end)

	renderPreview(brokenStory)
	expect(container:FindFirstChild("BrokenStoryFrame", true)).toBeDefined()

	expect(function()
		renderPreview(nextStory)
	end).never.toThrow()

	expect(container:FindFirstChild("Sibling", true)).toBeDefined()
end)
