local Group = require("@root/Group")
local Panel = require("@root/Panel")
local Window = require("@root/Window")

export type GroupProps = Group.GroupProps
export type PanelProps = Panel.PanelProps
export type WindowProps = Window.WindowProps

return {
	Group = Group,
	Panel = Panel,
	Window = Window,
}
