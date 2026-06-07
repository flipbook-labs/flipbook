return {
	-- Name of the CoreGui folder that holds the agent-facing BindableFunctions.
	FOLDER_NAME = "FlipbookAgentActions",
	-- CollectionService tag applied to each action Bindable for discovery.
	TAG = "FlipbookAgentAction",
	-- Bump when the manifest shape or result envelope changes in a breaking way.
	PROTOCOL_VERSION = 1,
	-- Prefix for all action ids to avoid PluginAction id collisions (global per
	-- session) and to disambiguate the CoreGui folder from other plugins.
	ID_NAMESPACE = "Flipbook/",
	-- Name of the discovery Bindable inside the folder.
	MANIFEST_NAME = "__manifest",
}
