local flipbook = script:FindFirstAncestor("flipbook")

local types = require(flipbook.types)
local tailwind = require(flipbook.tailwind)

return {
	Light = {
		textSize = 14,
		font = Enum.Font.GothamMedium,
		headerTextSize = 24,
		headerFont = Enum.Font.GothamBlack,

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
		alert = tailwind.rose500,

		padding = UDim.new(0, 12),
		paddingSmall = UDim.new(0, 6),
		paddingLarge = UDim.new(0, 24),

		corner = UDim.new(0, 6),
	} :: types.Theme,

	Dark = {
		textSize = 14,
		font = Enum.Font.GothamMedium,
		headerTextSize = 24,
		headerFont = Enum.Font.GothamBlack,

		background = tailwind.zinc800,
		sidebar = tailwind.zinc900,
		canvas = tailwind.zinc800,
		scrollbar = tailwind.zinc100,
		button = tailwind.zinc300,
		buttonText = tailwind.zinc900,
		divider = tailwind.zinc700,
		text = tailwind.zinc200,
		textFaded = tailwind.zinc300,
		selection = tailwind.purple500,
		story = tailwind.green500,
		directory = tailwind.purple500,
		alert = tailwind.rose500,

		padding = UDim.new(0, 12),
		paddingSmall = UDim.new(0, 6),
		paddingLarge = UDim.new(0, 24),

		corner = UDim.new(0, 6),
	} :: types.Theme,
}
