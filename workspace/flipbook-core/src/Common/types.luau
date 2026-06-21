export type Pluginlike = {
	GetMouse: (self: Pluginlike) -> PluginMouse,
	GetSetting: (self: Pluginlike, settingName: string) -> unknown,
	OpenScript: (self: Pluginlike, script: LuaSourceContainer, lineNumber: number?) -> (),
	SetSetting: (self: Pluginlike, settingName: string, value: unknown) -> (),
}

return nil
