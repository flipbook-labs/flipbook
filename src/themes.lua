local types = require(script.Parent.types)

return {
	Brand = Color3.fromHex("9333EA"),

	Light = {
		background = Color3.fromHex("F3F4F6"),
		canvas = Color3.fromHex("FFFFFF"),
		stroke = Color3.fromHex("D1D5DB"),
		text = Color3.fromHex("000000"),
		storybookEntry = Color3.fromHex("C4C4C4"),
		icons = {
			arrow = Color3.fromHex("C4C4C4"),
			folder = Color3.fromHex("6366F1"),
			search = Color3.fromHex("111228"),
			story = Color3.fromHex("4ADE80"),
		},
		searchbar = {
			background = Color3.fromHex("FFFFFF"),
			stroke = Color3.fromHex("9333EA"),
		},
		explorerEntry = {
			background = Color3.fromHex("FFFFFF"),
			selectedBackground = Color3.fromHex("6366F1"),
			selectedText = Color3.fromHex("FFFFFF"),
			text = Color3.fromHex("000000"),
		},
	} :: types.Theme,

	Dark = {
		background = Color3.fromHex("171717"),
		canvas = Color3.fromHex("1E1E1E"),
		stroke = Color3.fromHex("2B2B2B"),
		text = Color3.fromHex("FFFFFF"),
		storybookEntry = Color3.fromHex("5F5F5F"),
		icons = {
			arrow = Color3.fromHex("5F5F5F"),
			folder = Color3.fromHex("6366F1"),
			search = Color3.fromHex("FFFFFF"),
			story = Color3.fromHex("4ADE80"),
		},
		searchbar = {
			background = Color3.fromHex("121212"),
			stroke = Color3.fromHex("9333EA"),
		},
		explorerEntry = {
			background = Color3.fromHex("272727"),
			selectedBackground = Color3.fromHex("6366F1"),
			selectedText = Color3.fromHex("FFFFFF"),
			text = Color3.fromHex("FFFFFF"),
		},
	} :: types.Theme,
}
