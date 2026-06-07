--[[
	Types for the central Actions registry.

	An Action's behavior is written once (in `definitions/`) and exposed through
	two routers: a PluginAction mirror (human shortcuts) and a CoreGui
	BindableFunction registry (agent door). Both converge on `dispatch`.
]]

export type ActionResult = {
	ok: boolean,
	result: any?,
	error: string?,
}

export type AppState = {
	widgetOpen: boolean,
	screen: string,
	selectedStory: string?,
}

export type StoryInfo = {
	path: string,
	name: string,
}

-- The app-provided half of the controller. `FlipbookApp` registers this when it
-- mounts and clears it on unmount, so these are only available while the widget
-- is open.
export type AppControllerImpl = {
	navigateTo: (screen: string) -> (),
	selectStory: (path: string) -> ActionResult,
	listStories: () -> { StoryInfo },
	getState: () -> { screen: string, selectedStory: string? },
}

-- The seam actions use to reach app capabilities. `toggleWidget` is backed by
-- the dock widget directly (available at bootstrap); the rest delegate to the
-- registered `AppControllerImpl`.
export type AppController = {
	toggleWidget: (enabled: boolean?) -> (),
	navigateTo: (screen: string) -> ActionResult,
	selectStory: (path: string) -> ActionResult,
	listStories: () -> { StoryInfo },
	getState: () -> AppState,
	register: (impl: AppControllerImpl) -> () -> (),
}

export type ActionContext = {
	plugin: Plugin,
	controller: AppController,
}

export type ActionParam = {
	name: string,
	type: string,
	required: boolean?,
	description: string?,
}

export type Action = {
	id: string, -- namespaced, e.g. "Flipbook/SelectStory"
	text: string, -- human label (PluginAction text)
	statusTip: string, -- description (shortcuts window + agent manifest)
	iconName: string?, -- PluginAction icon
	allowBinding: boolean?, -- show in Studio shortcuts window (default true)
	params: { ActionParam }?, -- descriptive schema so the agent knows how to call it
	run: (ctx: ActionContext, payload: any) -> any,
}

export type ManifestEntry = {
	id: string,
	text: string,
	statusTip: string,
	params: { ActionParam }?,
}

export type ActionRegistry = {
	actions: { Action },
	dispatch: (id: string, payload: any) -> ActionResult,
	manifest: () -> { ManifestEntry },
}

return nil
