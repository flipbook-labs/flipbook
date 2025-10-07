local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local BuilderIcons = require(Packages.BuilderIcons)
local migrationLookup = BuilderIcons.Migration["uiblox"]

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local ButtonVariant = require(Foundation.Enums.ButtonVariant)
type ButtonVariant = ButtonVariant.ButtonVariant

-- IconButton and Button variants are not currently aligned, but eventually it should be.
-- For now we don't want to create a new variant enum for IconButton, so we'll use the Button variant enum
-- and extract only the supported variants.
type SupportedIconButtonVariant =
	typeof(ButtonVariant.Standard)
	| typeof(ButtonVariant.Emphasis)
	| typeof(ButtonVariant.Utility)
	| typeof(ButtonVariant.OverMedia)
	| typeof(ButtonVariant.Alert)

local Radius = require(Foundation.Enums.Radius)
type Radius = Radius.Radius

local useTokens = require(Foundation.Providers.Style.useTokens)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)
local useIconSize = require(Foundation.Utility.useIconSize)
local getIconScale = require(Foundation.Utility.getIconScale)
local useIconButtonVariants = require(script.Parent.useIconButtonVariants)
local isBuilderIcon = require(Foundation.Utility.isBuilderIcon)
local iconMigrationUtils = require(Foundation.Utility.iconMigrationUtils)
local isMigrated = iconMigrationUtils.isMigrated
local isBuilderOrMigratedIcon = iconMigrationUtils.isBuilderOrMigratedIcon

local Constants = require(Foundation.Constants)

local View = require(Foundation.Components.View)
local Text = require(Foundation.Components.Text)
local Image = require(Foundation.Components.Image)
local Types = require(Foundation.Components.Types)

export type IconButtonProps = {
	onActivated: () -> (),
	isDisabled: boolean?,
	isCircular: boolean?,
	-- Size of IconButton. `IconSize` is deprecated - use `InputSize`.
	-- `Large` and `XLarge` `IconSize`s map to `InputSize.Large` and are not supported.
	size: (InputSize | IconSize)?,
	variant: SupportedIconButtonVariant?,
	icon: string | {
		name: string,
		variant: BuilderIcons.IconVariant?,
	},
} & Types.SelectionProps & Types.CommonProps

local defaultProps = {
	isDisabled = false,
	size = InputSize.Medium,
	isCircular = false,
	variant = ButtonVariant.Utility,
}

local function IconButton(iconButtonProps: IconButtonProps, ref: React.Ref<GuiObject>?)
	local props = withDefaults(iconButtonProps, defaultProps)
	local tokens = useTokens()

	local iconName = if typeof(props.icon) == "table" then props.icon.name else props.icon
	local iconVariant: BuilderIcons.IconVariant? = if typeof(props.icon) == "table" then props.icon.variant else nil

	local intrinsicIconSize: Vector2?, scale
	if isBuilderOrMigratedIcon(iconName) then
		intrinsicIconSize, scale = nil, 1
	else
		intrinsicIconSize, scale = getIconScale(iconName, props.size)
	end

	-- Use variant system for styling
	local variantProps = useIconButtonVariants(tokens, props.size, props.variant)

	-- Override radius if circular
	local componentRadius = if props.isCircular
		then UDim.new(0, tokens.Radius.Circle)
		else UDim.new(0, variantProps.container.radius or tokens.Radius.Large)

	local iconSize = useIconSize(props.size, isBuilderIcon(iconName)) :: UDim2 -- We don't support bindings for IconButton size

	local cursor = React.useMemo(function()
		return {
			radius = componentRadius,
			offset = tokens.Size.Size_150,
			borderWidth = tokens.Stroke.Thicker,
		}
	end, { tokens :: unknown, componentRadius })

	return React.createElement(
		View,
		withCommonProps(props, {
			onActivated = props.onActivated,
			Size = variantProps.container.size,
			selection = {
				Selectable = if props.isDisabled then false else props.Selectable,
				NextSelectionUp = props.NextSelectionUp,
				NextSelectionDown = props.NextSelectionDown,
				NextSelectionLeft = props.NextSelectionLeft,
				NextSelectionRight = props.NextSelectionRight,
			},
			isDisabled = props.isDisabled,
			padding = variantProps.container.padding,
			cornerRadius = componentRadius,
			backgroundStyle = variantProps.container.style,
			stroke = variantProps.container.stroke,
			cursor = cursor,
			tag = variantProps.container.tag,
			GroupTransparency = if props.isDisabled then Constants.DISABLED_TRANSPARENCY else nil,
			ref = ref,
		}),
		{
			Icon = if isBuilderOrMigratedIcon(iconName)
				then React.createElement(Text, {
					Text = if isMigrated(iconName) then migrationLookup[iconName].name else iconName,
					fontStyle = {
						Font = BuilderIcons.Font[if isMigrated(iconName)
							then migrationLookup[iconName].variant
							else iconVariant or BuilderIcons.IconVariant.Regular],
						FontSize = iconSize.Y.Offset,
					},
					tag = "anchor-center-center position-center-center",
					Size = iconSize,
					textStyle = variantProps.content.style,
				})
				else React.createElement(Image, {
					tag = "anchor-center-center position-center-center",
					Image = iconName,
					Size = if intrinsicIconSize
						then UDim2.fromOffset(intrinsicIconSize.X, intrinsicIconSize.Y)
						else iconSize,
					imageStyle = variantProps.content.style,
					scale = scale,
				}),
		}
	)
end

return React.memo(React.forwardRef(IconButton))
