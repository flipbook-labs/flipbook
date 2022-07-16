local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local RoactSpring = require(flipbook.Packages.RoactSpring)
local assets = require(flipbook.assets)
local constants = require(flipbook.constants)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)
local mapRanges = require(flipbook.Modules.mapRanges)
local InputField = require(flipbook.Components.InputField)

local e = Roact.createElement

local defaultProps = {
	size = UDim2.new(1, 0, 0, 36),
}

type Props = typeof(defaultProps) & {
	layoutOrder: number?,
	onSearchChanged: ((value: string) -> ())?,
}

local SEARCH_ICON_SIZE = 16 -- px

local function Searchbar(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local search, setSearch = hooks.useState("")
	local isFocused, setIsFocused = hooks.useState(false)
	local isExpanded = isFocused or search ~= ""

	local styles = RoactSpring.useSpring(hooks, {
		alpha = if isExpanded then 1 else 0,
		-- config = constants.SPRING_CONFIG,
		config = { frequency = 0.1 },
	})

	local onFocus = hooks.useCallback(function()
		setIsFocused(true)
	end, { setIsFocused })

	local onFocusLost = hooks.useCallback(function()
		setIsFocused(false)
	end, { setIsFocused })

	local onTextChange = hooks.useCallback(function(new: string)
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
		[Roact.Event.Activated] = onFocus,
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

		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
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

		Icon = e("ImageLabel", {
			LayoutOrder = 2,
			Image = assets.Search,
			ImageTransparency = styles.alpha:map(function(alpha: number)
				return mapRanges(alpha, 0, 1, 0.5, 0)
			end),
			Size = UDim2.fromOffset(SEARCH_ICON_SIZE, SEARCH_ICON_SIZE),
			BackgroundTransparency = 1,
		}),
	})
end

return hook(Searchbar, {
	defaultProps = defaultProps,
})
