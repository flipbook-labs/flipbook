local JestGlobals = require("@pkg/JestGlobals")

local types = require("@root/types")

local expect = JestGlobals.expect
local test = JestGlobals.test

type ActionsState = {
	controls: types.Controls,
	embeddedOverwrite: boolean,
	embeddedParent: string?,
	opened: boolean,
}

local actions = require("@root/actions")

local function createActions(): (types.AgentActions, ActionsState)
	local state: ActionsState = {
		controls = { text = "Before" },
		embeddedOverwrite = false,
		embeddedParent = nil,
		opened = false,
	}
	local agentActions: types.AgentActions = {
		openWidget = function()
			state.opened = true
		end,
		embedFlipbook = function(parent, overwrite)
			state.embeddedParent = parent
			state.embeddedOverwrite = overwrite == true
			return "ReplicatedStorage/Flipbook"
		end,
		listStorybooks = function()
			return {
				{
					name = "Example",
					path = "ReplicatedStorage/Example.storybook",
				},
			}
		end,
		listStories = function(storybookPath)
			return {
				{
					name = "Button",
					path = `{storybookPath}/Button.story`,
					storybook = storybookPath,
				},
			}
		end,
		openStory = function(storyPath, storybookPath)
			return {
				name = "Button",
				path = storyPath,
				storybook = storybookPath,
			}
		end,
		getCurrentStory = function()
			return {
				name = "Button",
				path = "ReplicatedStorage/Button.story",
				isMounted = true,
			}
		end,
		getControls = function()
			return state.controls
		end,
		setControls = function(nextControls)
			state.controls = nextControls
			return state.controls
		end,
	}
	return agentActions, state
end

test("rejects params with non-string keys", function()
	local agentActions = createActions()

	expect(function()
		actions.listStories.run(agentActions, { [1] = "ReplicatedStorage/Example.storybook" })
	end).toThrow("params must use string keys")
end)

test("opens the widget", function()
	local agentActions, state = createActions()

	expect(actions.openWidget.run(agentActions, nil)).toEqual({ enabled = true })
	expect(state.opened).toBe(true)
end)

test("embeds Flipbook", function()
	local agentActions, state = createActions()

	expect(actions.embedFlipbook.run(agentActions, {
		parent = "ReplicatedStorage",
		overwrite = true,
	})).toEqual({ path = "ReplicatedStorage/Flipbook" })
	expect(state.embeddedParent).toBe("ReplicatedStorage")
	expect(state.embeddedOverwrite).toBe(true)
end)

test("lists storybooks", function()
	local agentActions = createActions()

	expect(actions.listStorybooks.run(agentActions, nil)).toEqual({
		storybooks = {
			{
				name = "Example",
				path = "ReplicatedStorage/Example.storybook",
			},
		},
	})
end)

test("lists stories", function()
	local agentActions = createActions()

	expect(actions.listStories.run(agentActions, { storybook = "ReplicatedStorage/Example.storybook" })).toEqual({
		stories = {
			{
				name = "Button",
				path = "ReplicatedStorage/Example.storybook/Button.story",
				storybook = "ReplicatedStorage/Example.storybook",
			},
		},
	})
end)

test("opens a story", function()
	local agentActions = createActions()

	expect(actions.openStory.run(agentActions, {
		story = "ReplicatedStorage/Button.story",
		storybook = "ReplicatedStorage/Example.storybook",
	})).toEqual({
		name = "Button",
		path = "ReplicatedStorage/Button.story",
		storybook = "ReplicatedStorage/Example.storybook",
	})
end)

test("gets the current story", function()
	local agentActions = createActions()

	expect(actions.getCurrentStory.run(agentActions, nil)).toEqual({
		name = "Button",
		path = "ReplicatedStorage/Button.story",
		isMounted = true,
	})
end)

test("gets controls", function()
	local agentActions = createActions()

	expect(actions.getControls.run(agentActions, nil)).toEqual({
		controls = { text = "Before" },
	})
end)

test("sets controls", function()
	local agentActions = createActions()

	expect(actions.setControls.run(agentActions, { controls = { text = "After" } })).toEqual({
		controls = { text = "After" },
	})
end)
