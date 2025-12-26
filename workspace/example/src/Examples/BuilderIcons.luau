local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

export type Props = {
	filter: string?,
}

local function BuilderIcons(props: Props)
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
				size = Foundation.Enums.InputSize.Large,
				LayoutOrder = 1,
			}),

			Label = React.createElement(Foundation.Text, {
				tag = "auto-xy content-default text-caption-small",
				Text = key,
				LayoutOrder = 2,
			}),
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
