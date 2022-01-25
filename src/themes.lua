local fromHex = require(script.Parent.Modules.fromHex)

return {
	Brand = fromHex(0x933EA),

	Light = {
		background = fromHex(0xF3F4F6),
		stroke = fromHex(0xD1D5DB),
		text = fromHex(0x000000),
		icons = {
			search = fromHex(0x111228),
		},
		searchbar = {
			stroke = fromHex(0x933EA),
			background = fromHex(0xFFFFFF),
		},
	},

	Dark = {
		background = fromHex(0x171717),
	},
}
