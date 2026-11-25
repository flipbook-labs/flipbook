local root = require("../../pkg")

return {
	package = {
		name = "TestRunner",
		version = root.package.metadata.version,
		files = root.package.metadata.memberFiles,
	},
}
