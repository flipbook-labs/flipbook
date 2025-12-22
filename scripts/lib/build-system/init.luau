local types = require("@self/types")

export type BuildContext = types.BuildContext

return {
	compileAsync = require("./compile"),
	compileWorkspaceMemberAsync = require("@self/compileWorkspaceMemberAsync"),
}
