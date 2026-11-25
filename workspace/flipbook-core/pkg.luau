local root = require("../../pkg")

return {
	package = {
		name = "FlipbookCore",
		version = root.package.metadata.version,
		files = root.package.metadata.memberFiles,
	},
}
