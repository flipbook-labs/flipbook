local constants = require("@self/constants")

return {
	FLIPBOOK_LOGO = constants.FLIPBOOK_LOGO,

	createFlipbookPlugin = require("@self/Plugin/createFlipbookPlugin"),
	createEmbeddedFlipbookApp = require("@self/Embedding/createEmbeddedFlipbookApp"),
}
