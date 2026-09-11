-- This mimics the Plugin interface enough for Flipbook's purposes without
-- depending on the actual Plugin object. We had to make this split to support
-- the embedded storybook flow where Flipbook was no longer just a Studio plugin.
--
-- Make sure to get the member types correct or we're going to have some fun
-- bugs to track down.
-- https://create.roblox.com/docs/en-us/reference/engine/classes/Plugin
export type Pluginlike = {
	GetMouse: (self: Pluginlike) -> PluginMouse,
	GetSetting: (self: Pluginlike, settingName: string) -> unknown,
	OpenScript: (self: Pluginlike, script: LuaSourceContainer, lineNumber: number?) -> (),
	SetSetting: (self: Pluginlike, settingName: string, value: unknown) -> (),
}

return nil
