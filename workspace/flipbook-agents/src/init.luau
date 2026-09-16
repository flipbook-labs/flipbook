local types = require("@root/types")

export type AgentActions = types.AgentActions
export type AgentController = types.AgentController
export type AppAdapter = types.AppAdapter
export type Controls = types.Controls
export type CurrentStory = types.CurrentStory
export type StoryAdapter = types.StoryAdapter
export type StoryInfo = types.StoryInfo
export type StorybookInfo = types.StorybookInfo

return {
	createAgentController = require("@root/createAgentController"),
	createAgentGateway = require("@root/createAgentGateway"),
	createEmbeddedAgentGateway = require("@root/createEmbeddedAgentGateway"),
}
