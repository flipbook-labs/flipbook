export type Args = {
	[string]: any,
}

export type Context = {
	target: Instance,
	element: unknown,
	args: Args?,
}

export type Renderer = {
	transformArgs: ((args: Args, context: Context) -> Args)?,
	shouldUpdate: ((context: Context, prevContext: Context?) -> boolean)?,
	mount: (target: Instance, element: unknown, context: Context) -> GuiObject | Folder,
	unmount: ((context: Context) -> ())?,
}

return nil
