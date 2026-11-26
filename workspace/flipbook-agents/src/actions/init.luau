local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local actions: { [string]: Action } = {
	embedFlipbook = require("@root/actions/embedFlipbook"),
	getControls = require("@root/actions/getControls"),
	getCurrentStory = require("@root/actions/getCurrentStory"),
	listStories = require("@root/actions/listStories"),
	listStorybooks = require("@root/actions/listStorybooks"),
	openStory = require("@root/actions/openStory"),
	openWidget = require("@root/actions/openWidget"),
	setControls = require("@root/actions/setControls"),
}

return actions
