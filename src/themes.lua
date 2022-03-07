local fromHex = require(script.Parent.Modules.fromHex)

return {
	Brand = fromHex(0x933EA),

	Light = {
		background = fromHex(0xF3F4F6),
		stroke = fromHex(0xD1D5DB),
		text = fromHex(0x000000),
		icons = {
			search = fromHex(0x111228),
			folder = fromHex(0x6366F1),
			story = fromHex(0x93C5FD),
		},
		searchbar = {
			background = fromHex(0xFFFFFF),
			stroke = fromHex(0x933EA),
		},
		entry = {
			background = fromHex(0xFFFFFF),
			text = fromHex(0x000000)
		}
	},
}