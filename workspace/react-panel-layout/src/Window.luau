local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Sift = require("@pkg/Sift")

local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

export type WindowProps = {
	id: string,
	title: string,
	plugin: Plugin,
	enabled: boolean?,
	initialDockState: Enum.InitialDockState?,
	initialSize: Vector2?,
	minSize: Vector2?,
	onEnabledChanged: ((enabled: boolean) -> ())?,
	children: React.Node?,
}

local defaultProps = {
	enabled = true,
	initialDockState = Enum.InitialDockState.Float,
	initialSize = Vector2.new(800, 600),
	minSize = Vector2.new(320, 240),
}

type Props = typeof(defaultProps) & WindowProps

local function Window(windowProps: WindowProps)
	local props: Props = Sift.Dictionary.join(defaultProps, windowProps)
	local initialEnabled = if props.enabled == nil then true else props.enabled

	local widget, setWidget = useState(nil :: any)
	local widgetRef = useRef(nil :: DockWidgetPluginGui?)

	useEffect(function()
		local alive = true
		local enabledConn: RBXScriptConnection? = nil

		task.spawn(function()
			local info = DockWidgetPluginGuiInfo.new(
				props.initialDockState,
				initialEnabled,
				false,
				props.initialSize.Y,
				props.initialSize.X,
				props.minSize.X,
				props.minSize.Y
			)

			local nextWidget: DockWidgetPluginGui?
			local ok, err = pcall(function()
				nextWidget = props.plugin:CreateDockWidgetPluginGuiAsync(props.id, info)
			end)

			if not (ok and nextWidget) then
				warn("Failed to create DockWidgetPluginGui for Window", err)
				return
			end

			if not alive then
				nextWidget:Destroy()
				return
			end

			nextWidget.Name = props.id
			nextWidget.Title = props.title
			nextWidget.Enabled = initialEnabled

			enabledConn = nextWidget:GetPropertyChangedSignal("Enabled"):Connect(function()
				if props.onEnabledChanged then
					props.onEnabledChanged(nextWidget.Enabled)
				end
			end)

			widgetRef.current = nextWidget
			setWidget(nextWidget)
		end)

		return function()
			alive = false
			if enabledConn then
				enabledConn:Disconnect()
			end
			if widgetRef.current then
				widgetRef.current:Destroy()
				widgetRef.current = nil
			end
			setWidget(nil)
		end
	end, { props.id, props.plugin } :: { unknown })

	useEffect(function()
		if widget then
			widget.Title = props.title
			if props.enabled ~= nil then
				widget.Enabled = props.enabled
			end
		end
	end, { widget, props.title, props.enabled } :: { unknown })

	if not widget then
		return nil
	end

	return ReactRoblox.createPortal({
		Root = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			Children = React.createElement(React.Fragment, nil, props.children),
		}),
	}, widget)
end

return Window
