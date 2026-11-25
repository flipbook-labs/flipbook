local root = require("../../pkg")

return {
	package = {
		name = "FlipbookAgents",
		version = root.package.metadata.version,
		files = root.package.metadata.memberFiles,
	},
}
