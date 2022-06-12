local flipbook = script:FindFirstAncestor("flipbook")
local assets = require(flipbook.assets)

return {
	Light = {
		Background = Color3.fromHex("F1F3F4"),
		BrandIcon = assets.IconLight,
		Canvas = Color3.fromHex("FFFFFF"),

		Text = Color3.fromHex("111228"),
		TextSecondary = Color3.fromHex("FFFFFF"),
		TextTertiary = Color3.fromHex("4B5563"),

		Stroke = Color3.fromHex("E2E3E7"),
		StrokeSecondary = Color3.fromHex("CCCFD6"),
		StrokeTertiary = Color3.fromHex("606674"),

		Selection = Color3.fromHex("5D54E7"),
		Component = Color3.fromHex("4ADE80"),
	},

	Dark = {
		Background = Color3.fromHex("F1F3F4"),
		BrandIcon = assets.IconLight,
		Canvas = Color3.fromHex("FFFFFF"),

		Text = Color3.fromHex("111228"),
		TextSecondary = Color3.fromHex("FFFFFF"),
		TextTertiary = Color3.fromHex("4B5563"),

		Stroke = Color3.fromHex("E2E3E7"),
		StrokeSecondary = Color3.fromHex("CCCFD6"),
		StrokeTertiary = Color3.fromHex("606674"),

		Selection = Color3.fromHex("5D54E7"),
		Component = Color3.fromHex("4ADE80"),
	},
}
