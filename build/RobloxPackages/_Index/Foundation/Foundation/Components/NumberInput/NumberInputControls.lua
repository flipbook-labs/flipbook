local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local BuilderIcons = require(Packages.BuilderIcons)

local useTokens = require(Foundation.Providers.Style.useTokens)

local Components = Foundation.Components
local View = require(Components.View)
local Image = require(Components.Image)
local Icon = require(Components.Icon)
local FoundationConstants = require(Foundation.Constants)
local Flags = require(Foundation.Utility.Flags)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local Types = require(Foundation.Components.Types)

local NumberInputControlsVariant = require(Foundation.Enums.NumberInputControlsVariant)
type NumberInputControlsVariant = NumberInputControlsVariant.NumberInputControlsVariant

local useNumberInputVariants = require(script.Parent.useNumberInputVariants)
local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local TEST_ID_INCREMENT_BUTTON = "--foundation-numberinput-increment"
local TEST_ID_DECREMENT_BUTTON = "--foundation-numberinput-decrement"

type NumberInputControlProps = {
	isDisabled: boolean,
	onClick: () -> (),
}

type NumberInputControlsProps = {
	variant: NumberInputControlsVariant,
	-- Size of the controls
	size: InputSize,
	increment: NumberInputControlProps,
	decrement: NumberInputControlProps,
	LayoutOrder: number?,
}

type StackedIconButtonProps = {
	onActivated: () -> (),
	isDisabled: boolean?,
	padding: Types.Padding,
	tag: string?,
	children: React.ReactNode?,
} & Types.CommonProps

local StackedIconButton = function(props: StackedIconButtonProps)
	local tokens = useTokens()
	local radius = UDim.new(0, tokens.Radius.Medium)

	local cursor = React.useMemo(function()
		return {
			radius = radius,
			offset = tokens.Size.Size_150,
			borderWidth = tokens.Stroke.Thicker,
		}
	end, { tokens })

	return React.createElement(
		View,
		withCommonProps(props, {
			onActivated = props.onActivated,
			isDisabled = props.isDisabled,
			selection = {
				Selectable = not props.isDisabled,
			},
			cursor = cursor,
			padding = props.padding,
			cornerRadius = radius,
			tag = props.tag,
		}),
		props.children
	)
end

local function SplitControls(props: NumberInputControlsProps)
	local tokens = useTokens()
	local variantProps = useNumberInputVariants(tokens, props.size)

	local outerBorderThickness = tokens.Stroke.Standard
	local outerBorderOffset = math.ceil(outerBorderThickness) * 2
	local buttonSize = UDim2.fromOffset(
		variantProps.splitButton.size - outerBorderOffset,
		variantProps.splitButton.size - outerBorderOffset
	)

	return React.createElement(React.Fragment, {}, {
		ControlIncrement = React.createElement(View, {
			onActivated = props.increment.onClick,
			isDisabled = props.increment.isDisabled,
			padding = variantProps.button.padding,
			Size = buttonSize,
			stroke = {
				Color = tokens.Color.Stroke.Emphasis.Color3,
				Transparency = math.lerp(
					tokens.Color.Stroke.Emphasis.Transparency,
					1,
					if props.increment.isDisabled then FoundationConstants.DISABLED_TRANSPARENCY else 0
				),
				Thickness = tokens.Stroke.Standard,
			},
			tag = variantProps.splitButton.tag,
			LayoutOrder = 1,
			GroupTransparency = if props.increment.isDisabled then FoundationConstants.DISABLED_TRANSPARENCY else nil,
			testId = TEST_ID_INCREMENT_BUTTON,
		}, {
			Icon = React.createElement(Icon, {
				name = BuilderIcons.Icon.PlusSmall,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
			}),
		}),
		ControlDecrement = React.createElement(View, {
			onActivated = props.decrement.onClick,
			isDisabled = props.decrement.isDisabled,
			padding = variantProps.button.padding,
			Size = buttonSize,
			stroke = {
				Color = tokens.Color.Stroke.Emphasis.Color3,
				Transparency = math.lerp(
					tokens.Color.Stroke.Emphasis.Transparency,
					1,
					if props.decrement.isDisabled then FoundationConstants.DISABLED_TRANSPARENCY else 0
				),
				Thickness = tokens.Stroke.Standard,
			},
			tag = variantProps.splitButton.tag,
			LayoutOrder = -1,
			GroupTransparency = if props.decrement.isDisabled then FoundationConstants.DISABLED_TRANSPARENCY else nil,
			testId = TEST_ID_DECREMENT_BUTTON,
		}, {
			Icon = React.createElement(Icon, {
				name = BuilderIcons.Icon.MinusSmall,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
			}),
		}),
	})
end

local function StackedControls(props: NumberInputControlsProps)
	local tokens = useTokens()
	local variantProps = useNumberInputVariants(tokens, props.size)

	local incrementImageStyle = React.useMemo(function()
		return {
			Color3 = tokens.Color.Stroke.Emphasis.Color3,
			Transparency = if props.increment.isDisabled then FoundationConstants.DISABLED_TRANSPARENCY else 0,
		}
	end, { tokens, props.increment.isDisabled } :: { unknown })

	local decrementImageStyle = React.useMemo(function()
		return {
			Color3 = tokens.Color.Stroke.Emphasis.Color3,
			Transparency = if props.decrement.isDisabled then FoundationConstants.DISABLED_TRANSPARENCY else 0,
		}
	end, { tokens, props.decrement.isDisabled } :: { unknown })

	return React.createElement(View, {
		tag = "col",
		Size = UDim2.new(0, variantProps.button.width, 1, 0),
		LayoutOrder = props.LayoutOrder,
	}, {
		ControlIncrement = React.createElement(StackedIconButton, {
			onActivated = props.increment.onClick,
			isDisabled = props.increment.isDisabled,
			padding = variantProps.button.padding,
			tag = variantProps.upButton.tag,
			testId = TEST_ID_INCREMENT_BUTTON,
		}, {
			Icon = React.createElement(Image, {
				Image = "component_assets/triangleUp_16",
				imageStyle = if Flags.FoundationNumberInputDisabledStackedVisual then incrementImageStyle else nil,
				tag = variantProps.icon.tag,
				testId = "--foundation-numberinput-stacked-increment-image",
			}),
		}),
		ControlDecrement = React.createElement(StackedIconButton, {
			tag = variantProps.downButton.tag,
			onActivated = props.decrement.onClick,
			isDisabled = props.decrement.isDisabled,
			padding = variantProps.button.padding,
			testId = TEST_ID_DECREMENT_BUTTON,
		}, {
			Icon = React.createElement(Image, {
				Image = "component_assets/triangleDown_16",
				imageStyle = if Flags.FoundationNumberInputDisabledStackedVisual then decrementImageStyle else nil,
				tag = variantProps.icon.tag,
				testId = "--foundation-numberinput-stacked-decrement-image",
			}),
		}),
	})
end

local function NumberInputControls(props: NumberInputControlsProps)
	if props.variant == NumberInputControlsVariant.Stacked then
		return React.createElement(StackedControls, props)
	else
		return React.createElement(SplitControls, props)
	end
end

return NumberInputControls
