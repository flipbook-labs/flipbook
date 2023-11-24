local flipbook = script

local RunService = game:GetService("RunService")
local ScriptEditorService = game:GetService("ScriptEditorService")

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local createWidget = require(flipbook.Plugin.createWidget)
local createToggleButton = require(flipbook.Plugin.createToggleButton)
local App = require(flipbook.Components.App)
local constants = require(flipbook.constants)
local analyzeStorybook = require(flipbook.AnalysisHints.analyzeStorybook)

local PLUGIN_NAME = "flipbook"

if constants.IS_DEV_MODE then
	PLUGIN_NAME = "flipbook [DEV]"
end

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local widget = createWidget(plugin, PLUGIN_NAME)
local root = ReactRoblox.createRoot(widget)
local disconnectButton = createToggleButton(toolbar, widget)

local loader = ModuleLoader.new()

local app = React.createElement(App, {
	plugin = plugin,
	loader = loader,
})

local widgetConn = widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	if widget.Enabled then
		root:render(app)
	else
		root:unmount()
		loader:clear()
	end
end)

if widget.Enabled then
	root:render(app)
end

local function registerScriptAnalysis()
	ScriptEditorService:RegisterScriptAnalysisCallback(
		constants.STORYBOOK_ANALYSIS_NAME,
		constants.STORYBOOK_ANALYSIS_PRIORITY,
		function(request)
			return analyzeStorybook(request.script)
		end
	)
end

local success = pcall(registerScriptAnalysis)
if not success then
	ScriptEditorService:DeregisterScriptAnalysisCallback(constants.STORYBOOK_ANALYSIS_NAME)
	registerScriptAnalysis()
end

plugin.Unloading:Connect(function()
	disconnectButton()
	widgetConn:Disconnect()

	root:unmount()
	loader:clear()
end)
