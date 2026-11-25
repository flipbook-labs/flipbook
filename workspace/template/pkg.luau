local root = require("../../pkg")

return {
	package = {
		name = "Template",
		version = root.package.metadata.version,
		files = root.package.metadata.memberFiles,
	},
}
