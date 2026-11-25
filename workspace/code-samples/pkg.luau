local root = require("../../pkg")

return {
	package = {
		name = "CodeSamples",
		version = root.package.metadata.version,
		files = root.package.metadata.memberFiles,
	},
}
