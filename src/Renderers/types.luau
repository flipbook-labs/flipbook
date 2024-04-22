export type Renderer = {
	transformArgs: ((args: { [string]: any }) -> { [string]: any })?,
	shouldUpdate: (() -> boolean)?,
	mount: (target: Instance, element: any) -> GuiObject | Folder,
	unmount: (() -> ())?,
}

return nil
