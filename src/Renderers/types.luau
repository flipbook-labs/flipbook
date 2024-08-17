local storyTypes = require("@root/Storybook/types")

export type Theme = "System" | "Light" | "Dark"
export type Args = {
	[string]: any,
}

export type Context = {
	-- theme: Theme,
	-- story: storyTypes.Story,
	-- storybook: storyTypes.Storybook,
	container: Instance,
	args: Args?,
}

export type Renderer = {
	mount: (container: Instance, element: unknown, context: Context?) -> (),

	unmount: ((context: Context?) -> ())?,
	update: ((context: Context?) -> ())?,
	transformArgs: ((args: Args, context: Context) -> Args)?,
	shouldUpdate: ((context: Context, prevContext: Context?) -> boolean)?,
}

return nil
