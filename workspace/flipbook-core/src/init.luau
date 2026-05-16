local constants = require("@self/constants")

return {
	FLIPBOOK_LOGO = constants.FLIPBOOK_LOGO,

	createFlipbookApp = require("@self/createFlipbookApp"),
	createFlipbookPlugin = require("@self/Plugin/createFlipbookPlugin"),
}
