local tailwind = require("@root/tailwind")

export type Theme = {
	textSize: number,
	font: Enum.Font,
	headerTextSize: number,
	headerFont: Enum.Font,
	buttonTextSize: number,
	buttonFont: Enum.Font,

	background: Color3,
	modal: Color3,
	sidebar: Color3,
	canvas: Color3,
	scrollbar: Color3,
	button: Color3,
	buttonText: Color3,
	divider: Color3,
	text: Color3,
	textFaded: Color3,
	selection: Color3,
	story: Color3,
	directory: Color3,

	padding: UDim,
	paddingSmall: UDim,
	paddingLarge: UDim,

	corner: UDim,
}

return {
	Light = {
		textSize = 18,
		font = Enum.Font.BuilderSansMedium,
		headerTextSize = 32,
		headerFont = Enum.Font.BuilderSansExtraBold,
		buttonTextSize = 14,
		buttonFont = Enum.Font.BuilderSansBold,

		background = tailwind.white,
		modal = tailwind.gray100,
		sidebar = tailwind.gray100,
		canvas = tailwind.white,
		scrollbar = tailwind.gray800,
		button = tailwind.gray800,
		buttonText = tailwind.white,
		divider = tailwind.gray300,
		text = tailwind.gray800,
		textFaded = tailwind.gray600,
		textSubtitle = tailwind.gray500,
		selection = tailwind.purple500,
		story = tailwind.green500,
		directory = tailwind.purple500,
		alert = tailwind.rose500,

		padding = UDim.new(0, 12),
		paddingSmall = UDim.new(0, 6),
		paddingLarge = UDim.new(0, 24),

		corner = UDim.new(0, 4),
	} :: Theme,

	Dark = {
		textSize = 18,
		font = Enum.Font.BuilderSansMedium,
		headerTextSize = 32,
		headerFont = Enum.Font.BuilderSansExtraBold,
		buttonTextSize = 14,
		buttonFont = Enum.Font.BuilderSansBold,

		background = tailwind.zinc800,
		modal = tailwind.zinc800,
		sidebar = tailwind.zinc900,
		canvas = tailwind.zinc800,
		scrollbar = tailwind.zinc100,
		button = tailwind.zinc300,
		buttonText = tailwind.zinc800,
		divider = tailwind.zinc700,
		text = tailwind.zinc200,
		textFaded = tailwind.zinc300,
		textSubtitle = tailwind.zinc400,
		selection = tailwind.purple500,
		story = tailwind.green500,
		directory = tailwind.purple500,
		alert = tailwind.rose500,

		padding = UDim.new(0, 12),
		paddingSmall = UDim.new(0, 6),
		paddingLarge = UDim.new(0, 24),

		corner = UDim.new(0, 6),
	} :: Theme,
}
