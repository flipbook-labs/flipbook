local flipbook = script:FindFirstAncestor("flipbook")
local types = require(flipbook.types)
local tailwind = require(flipbook.tailwind)

return {
	Light = {
		background = tailwind.white,
		sidebar = tailwind.gray100,
		canvas = tailwind.white,
		scrollbar = tailwind.gray800,
		button = tailwind.gray800,
		buttonText = tailwind.white,
		divider = tailwind.gray300,
		text = tailwind.gray800,
		textFaded = tailwind.gray600,
		selection = tailwind.purple500,
		story = tailwind.green500,
		directory = tailwind.purple500,

		padding = UDim.new(0, 12),
		paddingSmall = UDim.new(0, 6),
		paddingLarge = UDim.new(0, 24),
	} :: types.Theme,

	Dark = {
		background = tailwind.white,
		sidebar = tailwind.gray100,
		canvas = tailwind.white,
		scrollbar = tailwind.gray800,
		button = tailwind.gray800,
		buttonText = tailwind.white,
		divider = tailwind.gray300,
		text = tailwind.gray800,
		textFaded = tailwind.gray600,
		selection = tailwind.purple500,
		story = tailwind.green500,
		directory = tailwind.purple500,

		padding = UDim.new(0, 12),
		paddingSmall = UDim.new(0, 6),
		paddingLarge = UDim.new(0, 24),
	} :: types.Theme,
}
