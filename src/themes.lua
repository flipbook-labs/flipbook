local flipbook = script:FindFirstAncestor("flipbook")
local types = require(flipbook.types)
local tailwind = require(flipbook.tailwind)

return {
	Light = {
		background = tailwind.white,
		sidebar = tailwind.gray800,
		canvas = tailwind.white,
		scrollbar = tailwind.gray800,
		divider = tailwind.gray300,

		text = tailwind.gray800,
		textFaded = tailwind.gray600,

		button = tailwind.gray100,

		selection = tailwind.purple500,

		story = tailwind.green500,
		directory = tailwind.purple500,
	} :: types.Theme,

	Dark = {
		background = tailwind.white,
		brand = tailwind.purple500,
		sidebar = tailwind.gray800,
		canvas = tailwind.white,
		scrollbar = tailwind.gray800,
		divider = tailwind.gray300,

		text = tailwind.gray800,
		textFaded = tailwind.gray600,

		button = tailwind.gray100,

		selection = tailwind.purple500,

		story = tailwind.green500,
		directory = tailwind.purple500,
	} :: types.Theme,
}
