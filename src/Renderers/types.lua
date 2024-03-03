export type Args = {
	[string]: any,
}

export type Context = {
	args: Args,
	target: Instance,
}

export type Renderer = {
	transformArgs: ((args: Args, context: Context) -> Args)?,
	shouldUpdate: ((context: Context, prevContext: Context?) -> boolean)?,
	mount: (target: Instance, element: any, context: Context) -> GuiObject | Folder,
	unmount: ((context: Context) -> ())?,
}

return nil
