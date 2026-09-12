local types = require("@root/types")

export type AgentController = types.AgentController
export type AppImplementation = types.AppImplementation
export type Controls = types.Controls
export type CurrentStory = types.CurrentStory
export type StoryImplementation = types.StoryImplementation
export type StoryInfo = types.StoryInfo
export type StorybookInfo = types.StorybookInfo

return {
	createAgentController = require("@root/createAgentController"),
	createAgentGateway = require("@root/createAgentGateway"),
}
