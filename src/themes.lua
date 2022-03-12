local fromHex = require(script.Parent.Modules.fromHex)

return {
	Brand = fromHex(0x9333EA),

	Light = {
		background = fromHex(0xF3F4F6),
		stroke = fromHex(0xD1D5DB),
		text = fromHex(0x000000),
		storybookEntry = fromHex(0xC4C4C4),
		icons = {
			arrow = fromHex(0xC4C4C4),
			folder = fromHex(0x6366F1),
			search = fromHex(0x111228),
			story = fromHex(0x4ADE80),
		},
		searchbar = {
			background = fromHex(0xFFFFFF),
			stroke = fromHex(0x9333EA),
		},
		entry = {
			background = fromHex(0xFFFFFF),
			selectedBackground = fromHex(0x6366F1),
			selectedText = fromHex(0xFFFFFF),
			text = fromHex(0x000000),
		},
	},

	Dark = {
		background = fromHex(0x171717),
		stroke = fromHex(0x2B2B2B),
		text = fromHex(0xFFFFFF),
		storybookEntry = fromHex(0x5F5F5F),
		icons = {
			arrow = fromHex(0x5F5F5F),
			folder = fromHex(0x6366F1),
			search = fromHex(0xFFFFFF),
			story = fromHex(0x4ADE80),
		},
		searchbar = {
			background = fromHex(0x121212),
			stroke = fromHex(0x9333EA),
		},
		entry = {
			background = fromHex(0x272727),
			selectedBackground = fromHex(0x6366F1),
			selectedText = fromHex(0xFFFFFF),
			text = fromHex(0xFFFFFF),
		},
	},
}
