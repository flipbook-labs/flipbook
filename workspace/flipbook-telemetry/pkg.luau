local root = require("../../pkg")

return {
	package = {
		name = "FlipbookTelemetry",
		version = root.package.metadata.version,
		files = root.package.metadata.memberFiles,
	},
}
