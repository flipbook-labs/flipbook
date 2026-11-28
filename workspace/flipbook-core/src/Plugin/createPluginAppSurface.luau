export type SurfaceName = "viewport" | "widget"

export type PluginAppSurface = {
	container: Frame,
	destroy: () -> (),
	getName: () -> SurfaceName,
	isVisible: () -> boolean,
	openViewport: () -> (),
	openWidget: () -> (),
}

--[[
	Gives the app one container that can sit in the plugin widget or in a
	ScreenGui under `screenParent`. Reparenting the container keeps the React tree
	mounted, so the open story and its controls survive the move.

	`onVisibilityChanged` runs when the app becomes visible or hidden. Moving a
	visible app between surfaces doesn't run it, and neither does `destroy`.
]]
local function createPluginAppSurface(
	widget: DockWidgetPluginGui,
	screenParent: Instance,
	onVisibilityChanged: (isVisible: boolean) -> ()
): PluginAppSurface
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FlipbookViewport"
	-- Keeps the app out of saved places and Play sessions.
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

	local function isVisible(): boolean
		return if name == "viewport" then screenGui.Enabled else widget.Enabled
	end

	local wasVisible = isVisible()

	local function notifyIfVisibilityChanged()
		local visible = isVisible()
		if visible ~= wasVisible then
			wasVisible = visible
			onVisibilityChanged(visible)
		end
	end

	local function moveToWidget()
		name = "widget"
		screenGui.Enabled = false
		container.Parent = widget
	end

	local function openViewport()
		name = "viewport"
		container.Parent = screenGui
		screenGui.Enabled = true
		widget.Enabled = false
		notifyIfVisibilityChanged()
	end

	local function openWidget()
		moveToWidget()
		widget.Enabled = true
		notifyIfVisibilityChanged()
	end

	local widgetConnection = widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		-- Studio can open the widget on its own. The
		-- app follows, because an open widget without it would be empty.
		if widget.Enabled and name == "viewport" then
			moveToWidget()
		end
		notifyIfVisibilityChanged()
	end)

	local function destroy()
		widgetConnection:Disconnect()
		container:Destroy()
		screenGui:Destroy()
	end

	return {
		container = container,
		destroy = destroy,
		getName = function()
			return name
		end,
		isVisible = isVisible,
		openViewport = openViewport,
		openWidget = openWidget,
	}
end

return createPluginAppSurface
