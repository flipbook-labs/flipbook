export type Args = {
	[string]: any,
}

export type Context = {
	container: Instance,
	args: Args?,
}

export type Renderer = {
	mount: (container: Instance, element: unknown, context: Context) -> GuiObject | Folder,

	transformArgs: ((args: Args, context: Context) -> Args)?,
	shouldUpdate: ((context: Context, prevContext: Context?) -> boolean)?,
	unmount: ((context: Context) -> ())?,
}

return nil
