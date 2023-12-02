local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ReactSpring = require(flipbook.Packages.ReactSpring)
local Sift = require(flipbook.Packages.Sift)
local assets = require(flipbook.assets)
local constants = require(flipbook.constants)
local useTheme = require(flipbook.Hooks.useTheme)
local mapRanges = require(flipbook.Modules.mapRanges)
local InputField = require(flipbook.Components.InputField)
local Sprite = require(flipbook.Components.Sprite)

local e = React.createElement

local defaultProps = {
	size = UDim2.new(1, 0, 0, 36),
}

type Props = typeof(defaultProps) & {
	layoutOrder: number?,
	onSearchChanged: ((value: string) -> ())?,
}

local SEARCH_ICON_SIZE = 16 -- px

local function Searchbar(props: Props)
	props = Sift.Dictionary.merge(defaultProps, props)

	local theme = useTheme()
	local search, setSearch = React.useState("")
	local isFocused, setIsFocused = React.useState(false)
	local isExpanded = isFocused or search ~= ""

	local styles = (ReactSpring.useSpring :: any)({
		alpha = if isExpanded then 1 else 0,
		config = constants.SPRING_CONFIG,
	})

	local onFocus = React.useCallback(function()
		setIsFocused(true)
	end, { setIsFocused })

	local onFocusLost = React.useCallback(function()
		setIsFocused(false)
	end, { setIsFocused })

	local onTextChange = React.useCallback(function(new: string)
		if props.onSearchChanged then
			props.onSearchChanged(new)
		end

		setSearch(new)
	end, {})

	return e("ImageButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.background,
		LayoutOrder = props.layoutOrder,
		Size = props.size,
		[React.Event.Activated] = onFocus,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = theme.corner,
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
			PaddingRight = theme.padding,
			PaddingTop = theme.padding,
		}),

		UIStroke = e("UIStroke", {
			Color = styles.alpha:map(function(alpha: number)
				return theme.divider:Lerp(Color3.fromHex("fff"), alpha)
			end),
		}),

		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		InputFieldWrapper = e("Frame", {
			LayoutOrder = 1,
			Size = styles.alpha:map(function(alpha: number)
				-- This represents the width taken up by the Icon element and
				-- the layout's padding. We need to subtract it from the full
				-- width to make sure everything fits perfectly
				local remainingWidth = UDim2.fromOffset(SEARCH_ICON_SIZE, 0)
				local goal = UDim2.fromScale(1, 1) - remainingWidth

				return UDim2.fromScale(0, 1):Lerp(goal, alpha)
			end),
			BackgroundTransparency = 1,
		}, {
			InputField = isExpanded and e(InputField, {
				placeholder = "Enter component name...",
				autoFocus = true,
				onFocus = onFocus,
				onFocusLost = onFocusLost,
				onTextChange = onTextChange,
			}),
		}),

		Icon = e(Sprite, {
			layoutOrder = 2,
			image = assets.Search,
			transparency = styles.alpha:map(function(alpha: number)
				return mapRanges(alpha, 0, 1, 0.5, 0)
			end),
			size = UDim2.fromOffset(SEARCH_ICON_SIZE, SEARCH_ICON_SIZE),
		}),
	})
end

return Searchbar
