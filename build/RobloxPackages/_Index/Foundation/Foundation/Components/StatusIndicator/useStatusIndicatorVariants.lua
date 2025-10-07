local Foundation = script:FindFirstAncestor("Foundation")

local StatusIndicatorVariant = require(Foundation.Enums.StatusIndicatorVariant)
type StatusIndicatorVariant = StatusIndicatorVariant.StatusIndicatorVariant

local Types = require(Foundation.Components.Types)
type ColorStyleValue = Types.ColorStyleValue

local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)

type StatusIndicatorVariantProps = {
	container: { tag: string },
	content: { tag: string, style: ColorStyleValue },
}

function variantsFactory(tokens: Tokens)
	local common = {
		container = {
			tag = "radius-circle",
		},
		content = {
			tag = "auto-xy text-caption-small",
		},
	}

	local variants: { [StatusIndicatorVariant]: VariantProps } = {
		[StatusIndicatorVariant.Alert] = {
			container = {
				tag = "bg-system-alert",
			},
			content = {
				style = tokens.DarkMode.Content.Emphasis,
			},
		},
		[StatusIndicatorVariant.Success] = {
			container = {
				tag = "bg-system-success",
			},
			content = {
				style = tokens.LightMode.Content.Emphasis,
			},
		},
		[StatusIndicatorVariant.Warning] = {
			container = {
				tag = "bg-system-warning",
			},
			content = {
				style = tokens.LightMode.Content.Emphasis,
			},
		},
		[StatusIndicatorVariant.Emphasis] = {
			container = {
				tag = "bg-system-emphasis",
			},
			content = {
				style = tokens.DarkMode.Content.Emphasis,
			},
		},
		[StatusIndicatorVariant.Neutral] = {
			container = {
				tag = "bg-system-neutral",
			},
			content = {
				style = tokens.Inverse.Content.Emphasis,
			},
		},
		[StatusIndicatorVariant.Standard] = {
			container = {
				tag = "bg-action-standard",
			},
			content = {
				style = tokens.Color.Content.Emphasis,
			},
		},
	}

	local hasValue: { [boolean]: any } = {
		[false] = { container = { tag = "size-200-200" } },
		[true] = { container = { tag = "size-400-400 auto-x row align-y-center align-x-center padding-xsmall" } },
	}

	return { common = common, variants = variants, hasValue = hasValue }
end

return function(tokens: Tokens, variant: StatusIndicatorVariant, hasValue: boolean): StatusIndicatorVariantProps
	local props = VariantsContext.useVariants("StatusIndicator", variantsFactory, tokens)
	return composeStyleVariant(props.common, props.variants[variant], props.hasValue[hasValue])
end
