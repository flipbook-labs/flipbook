local AgentGateway = require("@pkg/AgentGateway")
local JestGlobals = require("@pkg/JestGlobals")

local actions = require("@root/actions")
local types = require("@root/types")

local expect = JestGlobals.expect
local test = JestGlobals.test

type Action = AgentGateway.Action<types.AgentController>
type ActionMap = { [string]: Action }
type ControllerState = {
	controls: types.Controls,
	embeddedOverwrite: boolean,
	embeddedParent: string?,
	opened: boolean,
}

local function indexActions(): ActionMap
	local result: ActionMap = {}
	for _, action in actions.create() do
		result[action.name] = action
	end
	return result
end

local function createController(): (types.AgentController, ControllerState)
	local state: ControllerState = {
		controls = { text = "Before" },
		embeddedOverwrite = false,
		embeddedParent = nil,
		opened = false,
	}
	local controller: types.AgentController = {
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
		registerApp = function()
			return function() end
		end,
		registerStory = function()
			return function() end
		end,
	}
	return controller, state
end

test("rejects params with non-string keys", function()
	local indexed = indexActions()
	local controller = createController()

	expect(function()
		indexed.listStories.run(controller, { [1] = "ReplicatedStorage/Example.storybook" })
	end).toThrow("params must use string keys")
end)

test("routes widget and embedding actions through the controller", function()
	local indexed = indexActions()
	local controller, state = createController()

	expect(indexed.openWidget.run(controller, nil)).toEqual({ enabled = true })
	expect(state.opened).toBe(true)

	expect(indexed.embedFlipbook.run(controller, {
		parent = "ReplicatedStorage",
		overwrite = true,
	})).toEqual({ path = "ReplicatedStorage/Flipbook" })
	expect(state.embeddedParent).toBe("ReplicatedStorage")
	expect(state.embeddedOverwrite).toBe(true)
end)

test("routes story actions through the controller", function()
	local indexed = indexActions()
	local controller = createController()

	expect(indexed.listStorybooks.run(controller, nil)).toEqual({
		storybooks = {
			{
				name = "Example",
				path = "ReplicatedStorage/Example.storybook",
			},
		},
	})
	expect(indexed.listStories.run(controller, { storybook = "ReplicatedStorage/Example.storybook" })).toEqual({
		stories = {
			{
				name = "Button",
				path = "ReplicatedStorage/Example.storybook/Button.story",
				storybook = "ReplicatedStorage/Example.storybook",
			},
		},
	})
	expect(indexed.openStory.run(controller, {
		story = "ReplicatedStorage/Button.story",
		storybook = "ReplicatedStorage/Example.storybook",
	})).toEqual({
		name = "Button",
		path = "ReplicatedStorage/Button.story",
		storybook = "ReplicatedStorage/Example.storybook",
	})
	expect(indexed.getCurrentStory.run(controller, nil)).toEqual({
		name = "Button",
		path = "ReplicatedStorage/Button.story",
		isMounted = true,
	})
end)

test("routes control actions through the controller", function()
	local indexed = indexActions()
	local controller = createController()

	expect(indexed.getControls.run(controller, nil)).toEqual({
		controls = { text = "Before" },
	})
	expect(indexed.setControls.run(controller, { controls = { text = "After" } })).toEqual({
		controls = { text = "After" },
	})
end)
