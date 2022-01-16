local Branding = require(script.Parent.Branding)
local LibraryHeader = require(script.Parent.LibraryHeader)
local Roact = require(script.Parent.Parent.Packages.Roact)
local Searchbar = require(script.Parent.Searchbar)

local PADDING = UDim.new(0, 20)
local NO_PADDING = UDim.new(0, 0)

type Props = {
	isExpanded: boolean,
	layoutOrder: number,
	width: NumberRange,
}

local function Sidebar(props: Props)
	local width = props.isExpanded and props.width.Max or props.width.Min

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0, width, 1, 0),
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingLeft = PADDING,
			PaddingRight = NO_PADDING,
			PaddingTop = PADDING,
			PaddingBottom = PADDING,
		}),

		Branding = Roact.createElement(Branding, {
			size = 20,
		}),

		Searchbar = Roact.createElement(Searchbar, {
			position = UDim2.fromOffset(0, 45),
		}),

		LibraryHeader = Roact.createElement(LibraryHeader),
	})
end

return Sidebar
