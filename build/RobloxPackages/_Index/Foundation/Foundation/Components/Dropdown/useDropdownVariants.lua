local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local Cryo = require(Packages.Cryo)

local Types = require(Foundation.Components.Types)
type ColorStyleValue = Types.ColorStyleValue
type Padding = Types.Padding

local ControlState = require(Foundation.Enums.ControlState)
type ControlState = ControlState.ControlState

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local InputLabelSize = require(Foundation.Enums.InputLabelSize)
type InputLabelSize = InputLabelSize.InputLabelSize

local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)

type DropdownVariantProps = {
	container: { tag: string, height: UDim },
	text: { tag: string },
	arrow: { size: IconSize },
}

type State = ControlState | "Error"

local function variantsFactory(tokens: Tokens)
	local common = {
		container = { tag = "row align-y-center flex-x-between stroke-standard" },
		text = {
			tag = "auto-xy text-truncate-split shrink",
		},
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = {
				-- TODO (AleksandrSl 26/06/2025): Drop height from containers of all sizes, when FoundationFixInputFieldWidth flag is removed
				height = UDim.new(0, tokens.Size.Size_600),
				tag = "radius-small padding-small gap-xxsmall size-full-600",
			},
			text = { tag = "text-body-small" },
			arrow = { size = InputSize.Small },
		},
		[InputSize.Small] = {
			container = {
				height = UDim.new(0, tokens.Size.Size_800),
				tag = "radius-medium padding-medium gap-xxsmall size-full-800",
			},
			text = { tag = "text-body-small" },
			arrow = { size = InputSize.Small },
		},
		[InputSize.Medium] = {
			container = {
				size = UDim2.new(1, 0, 0, tokens.Size.Size_1000),
				height = UDim.new(0, tokens.Size.Size_1000),
				tag = "radius-medium padding-medium size-full-1000",
			},
			text = { tag = "text-body-medium" },
			arrow = { size = InputSize.Medium },
		},
		[InputSize.Large] = {
			container = {
				size = UDim2.new(1, 0, 0, tokens.Size.Size_1200),
				height = UDim.new(0, tokens.Size.Size_1200),
				tag = "radius-medium padding-medium size-full-1200",
			},
			text = { tag = "text-body-large" },
			arrow = { size = InputSize.Medium },
		},
	}

	local states: { [State]: VariantProps } = {
		[ControlState.Disabled] = {
			container = { tag = "stroke-muted" },
			text = { tag = "content-muted" },
		},
		[ControlState.Initialize] = {
			container = { tag = "stroke-default" },
			text = { tag = "content-default" },
		},
		[ControlState.Default] = {
			container = { tag = "stroke-default" },
			text = { tag = "content-default" },
		},
		[ControlState.Hover] = {
			container = { tag = "stroke-emphasis" },
			text = { tag = "content-emphasis" },
		},
		[ControlState.Pressed] = {
			container = { tag = "stroke-emphasis" },
			text = { tag = "content-emphasis" },
		},
		-- TODO: Error states do not currently have hover / etc effects
		Error = {
			container = { tag = "stroke-alert" },
			text = { tag = "content-default" },
		},
	}

	-- Placeholder existence should take precendent of content styling in any case.
	-- It should always be content-muted.
	local placeholderStates = Cryo.Dictionary.map(states, function(state)
		return Cryo.Dictionary.join(state, {
			text = { tag = "content-muted" },
		})
	end)

	return {
		common = common,
		sizes = sizes,
		states = states,
		placeholderStates = placeholderStates,
	}
end

return function(
	tokens: Tokens,
	size: InputSize,
	controlState: ControlState,
	isPlaceholderShown: boolean,
	hasError: boolean
): DropdownVariantProps
	local props = VariantsContext.useVariants("Dropdown", variantsFactory, tokens)
	local state = if hasError then "Error" else controlState
	return composeStyleVariant(
		props.common,
		props.sizes[size],
		if isPlaceholderShown then props.placeholderStates[state] else props.states[state :: State]
	)
end
