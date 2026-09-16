export type SurfaceName = "viewport" | "widget"

export type PluginAppSurface = {
	container: Frame,
	destroy: () -> (),
	getName: () -> SurfaceName,
	isVisible: () -> boolean,
	onVisibilityChanged: (callback: (boolean) -> ()) -> () -> (),
	openViewport: () -> (),
	openWidget: () -> (),
}

local function createPluginAppSurface(widget: DockWidgetPluginGui, screenParent: Instance): PluginAppSurface
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FlipbookViewport"
	screenGui.Archivable = false
	screenGui.Enabled = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = screenParent

	local container = Instance.new("Frame")
	container.Name = "FlipbookApp"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.fromScale(1, 1)
	container.Parent = widget

	local name: SurfaceName = "widget"
	local visibilityChanged = Instance.new("BindableEvent")
	local changingSurface = false

	local function isVisible(): boolean
		return if name == "viewport" then screenGui.Enabled else widget.Enabled
	end

	local function setSurface(nextName: SurfaceName)
		changingSurface = true
		name = nextName

		if nextName == "viewport" then
			container.Parent = screenGui
			screenGui.Enabled = true
			widget.Enabled = false
		else
			screenGui.Enabled = false
			container.Parent = widget
			widget.Enabled = true
		end

		changingSurface = false
		visibilityChanged:Fire(isVisible())
	end

	local widgetConnection = widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		if changingSurface then
			return
		end

		if widget.Enabled and name == "viewport" then
			name = "widget"
			screenGui.Enabled = false
			container.Parent = widget
		end
		visibilityChanged:Fire(isVisible())
	end)

	return {
		container = container,
		destroy = function()
			widgetConnection:Disconnect()
			visibilityChanged:Destroy()
			screenGui:Destroy()
		end,
		getName = function()
			return name
		end,
		isVisible = isVisible,
		onVisibilityChanged = function(callback)
			local connection = visibilityChanged.Event:Connect(callback)
			return function()
				connection:Disconnect()
			end
		end,
		openViewport = function()
			setSurface("viewport")
		end,
		openWidget = function()
			setSurface("widget")
		end,
	}
end

return createPluginAppSurface
