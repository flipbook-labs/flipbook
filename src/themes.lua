local types = require(script.Parent.types)

return {
	Brand = Color3.fromHex("9333EA"),

	Light = {
		background = Color3.fromHex("F3F4F6"),
		brand = Color3.fromHex("9333EA"),
		canvas = Color3.fromHex("FFFFFF"),
		component = Color3.fromHex("4ADE80"),
		stroke = Color3.fromHex("D1D5DB"),
		strokeSecondary = Color3.fromHex("B9BDC2"),
		text = Color3.fromHex("111228"),
		textSecondary = Color3.fromHex("FFFFFF"),
	} :: types.Theme,

	Dark = {
		background = Color3.fromHex("171717"),
		brand = Color3.fromHex("9333EA"),
		canvas = Color3.fromHex("1E1E1E"),
		component = Color3.fromHex("4ADE80"),
		stroke = Color3.fromHex("2B2B2B"),
		strokeSecondary = Color3.fromHex("3A3A3A"),
		text = Color3.fromHex("FFFFFF"),
		textSecondary = Color3.fromHex("111228"),
	} :: types.Theme,
}
