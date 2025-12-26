local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

export type Props = {
	filter: string?,
	iconSize: Foundation.InputSize?,
	showLabels: boolean?,
}

local defaultProps = {
	iconSize = Foundation.Enums.InputSize.Large,
	showLabels = true,
}

type InternalProps = typeof(defaultProps) & Props

local function BuilderIcons(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.join(defaultProps, providedProps)
	local children: { [string]: React.Node } = {}
	local order = 1

	for key, iconName in Foundation.Enums.IconName :: { [string]: string } do
		if props.filter and props.filter ~= "" then
			if not key:find(props.filter) and not iconName:match(props.filter) then
				continue
			end
		end

		children[key] = React.createElement(Foundation.View, {
			tag = "auto-xy col gap-small padding-medium bg-surface-100 align-x-center radius-small",
			LayoutOrder = order,
		}, {
			Icon = React.createElement(Foundation.Icon, {
				name = iconName,
				size = Foundation.Enums.InputSize[props.iconSize],
				LayoutOrder = 1,
			}),

			Label = if props.showLabels
				then React.createElement(Foundation.Text, {
					tag = "auto-xy content-default text-caption-small",
					Text = key,
					LayoutOrder = 2,
				})
				else nil,
		})

		order += 1
	end

	-- Never incremented this, so there's no icons to display
	if order == 1 then
		children.NoResults = React.createElement(Foundation.Text, {
			tag = "auto-xy content-alert text-body-medium",
			Text = `No icons found for filter "{props.filter}"`,
		})
	end

	return React.createElement(Foundation.View, {
		tag = "auto-xy wrap flex-between gap-small",
		layout = {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.Name,
		},
	}, children)
end

return BuilderIcons
