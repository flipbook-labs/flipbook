local root = require("../../pkg")

return {
	package = {
		name = "Example",
		version = root.package.metadata.version,
		files = root.package.metadata.memberFiles,
	},
}
