local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

local getControls = require("@root/actions/getControls")
local getCurrentStory = require("@root/actions/getCurrentStory")
local listStories = require("@root/actions/listStories")
local listStorybooks = require("@root/actions/listStorybooks")
local openStory = require("@root/actions/openStory")
local setControls = require("@root/actions/setControls")

type Action = AgentGateway.Action<types.AgentController>

local function createEmbedded(): { Action }
	return {
		listStorybooks,
		listStories,
		openStory,
		getCurrentStory,
		getControls,
		setControls,
	}
end

return createEmbedded
