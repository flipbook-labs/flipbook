local root = require("../../pkg")

return {
	package = {
		name = "FlipbookNext",
		version = root.package.metadata.version,
		files = root.package.metadata.memberFiles,
	},
}
