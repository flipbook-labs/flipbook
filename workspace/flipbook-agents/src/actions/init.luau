local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

local embedFlipbook = require("@root/actions/embedFlipbook")
local getControls = require("@root/actions/getControls")
local getCurrentStory = require("@root/actions/getCurrentStory")
local listStories = require("@root/actions/listStories")
local listStorybooks = require("@root/actions/listStorybooks")
local openStory = require("@root/actions/openStory")
local openWidget = require("@root/actions/openWidget")
local setControls = require("@root/actions/setControls")

type Action = AgentGateway.Action<types.AgentController>

local function create(): { Action }
	return {
		openWidget,
		embedFlipbook,
		listStorybooks,
		listStories,
		openStory,
		getCurrentStory,
		getControls,
		setControls,
	}
end

return {
	create = create,
}
