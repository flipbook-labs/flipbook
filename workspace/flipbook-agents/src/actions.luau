local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local function asTable(params: unknown?): { [string]: unknown }
	if type(params) ~= "table" then
		return {}
	end
	return params :: { [string]: unknown }
end

local function getRequiredString(params: { [string]: unknown }, key: string): string
	local value = params[key]
	if type(value) ~= "string" or value == "" then
		error(`{key} must be a non-empty string`)
	end
	return value
end

local function getOptionalString(params: { [string]: unknown }, key: string): string?
	local value = params[key]
	if value == nil then
		return nil
	end
	if type(value) ~= "string" or value == "" then
		error(`{key} must be a non-empty string when provided`)
	end
	return value
end

local function create(): { Action }
	return {
		{
			name = "openWidget",
			title = "Open Widget",
			description = "Open the Flipbook plugin widget.",
			run = function(controller)
				controller.openWidget()
				return { enabled = true }
			end,
		},
		{
			name = "listStorybooks",
			title = "List Storybooks",
			description = "List Storybooks currently available to Flipbook.",
			run = function(controller)
				return { storybooks = controller.listStorybooks() }
			end,
		},
		{
			name = "listStories",
			title = "List Stories",
			description = "List Story modules for one available Storybook.",
			inputSchema = {
				type = "object",
				properties = {
					storybook = { type = "string", description = "Path to a .storybook ModuleScript" },
				} :: { [string]: unknown },
				required = { "storybook" },
			},
			run = function(controller, params)
				local fields = asTable(params)
				return { stories = controller.listStories(getRequiredString(fields, "storybook")) }
			end,
		},
		{
			name = "openStory",
			title = "Open Story",
			description = "Open a Story module in Flipbook.",
			inputSchema = {
				type = "object",
				properties = {
					story = { type = "string", description = "Path to a .story ModuleScript" },
					storybook = { type = "string", description = "Optional path to its .storybook ModuleScript" },
				} :: { [string]: unknown },
				required = { "story" },
			},
			run = function(controller, params)
				local fields = asTable(params)
				return controller.openStory(getRequiredString(fields, "story"), getOptionalString(fields, "storybook"))
			end,
		},
		{
			name = "getCurrentStory",
			title = "Get Current Story",
			description = "Return the selected Story and whether its view is mounted.",
			run = function(controller)
				return controller.getCurrentStory()
			end,
		},
		{
			name = "getControls",
			title = "Get Controls",
			description = "Return effective control values for the mounted Story.",
			run = function(controller)
				return { controls = controller.getControls() }
			end,
		},
		{
			name = "setControls",
			title = "Set Controls",
			description = "Set control values for the mounted Story.",
			inputSchema = {
				type = "object",
				properties = {
					controls = { type = "object", description = "Map of control names to values" },
				} :: { [string]: unknown },
				required = { "controls" },
			},
			run = function(controller, params)
				local controls = asTable(params).controls
				if type(controls) ~= "table" then
					error("controls must be a table")
				end
				for key in controls :: { [unknown]: unknown } do
					if type(key) ~= "string" then
						error("control names must be strings")
					end
				end
				return { controls = controller.setControls(controls :: { [string]: unknown }) }
			end,
		},
	}
end

return {
	create = create,
}
