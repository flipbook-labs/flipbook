local function createWidget(plugin: Plugin, name: string): DockWidgetPluginGui
	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Top, true)

	local widget = plugin:CreateDockWidgetPluginGui(name, info)
	widget.Name = name
	widget.Title = name
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	return widget
end

return createWidget
