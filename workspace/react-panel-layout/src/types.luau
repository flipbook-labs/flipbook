local React = require("@pkg/React")

-- Sizes stored as grow weights (equivalent to percentages within the group).
-- Keys are panel IDs, values are grow ratios.
export type LayoutSizes = { [string]: number }

export type PanelGroupContext = {
	sizes: LayoutSizes,
	orientation: "horizontal" | "vertical",
	groupAbsoluteSize: Vector2,
	separatorsTotalSize: number,
	updateSizes: (newSizes: LayoutSizes) -> (),
	registerPanel: (id: string, defaultSize: number, constraints: NumberRange?) -> (),
	unregisterPanel: (id: string) -> (),
	panelConstraints: { [string]: NumberRange },
	registerSeparator: (separatorSize: number) -> (),
	unregisterSeparator: (separatorSize: number) -> (),
}

export type GroupProps = {
	id: string,
	orientation: "horizontal" | "vertical",
	defaultLayout: LayoutSizes?,
	onLayoutChange: ((id: string, sizes: LayoutSizes) -> ())?,
	children: React.Node?,
}

export type PanelProps = {
	id: string?,
	label: string?,
	LayoutOrder: number?,
	defaultSize: number?,
	sizeConstraints: NumberRange?,
	children: React.Node?,
}

-- Internal — not part of the public API
export type PanelSeparatorProps = {
	LayoutOrder: number,
	beforeId: string,
	afterId: string,
	hitboxSize: number?,
	visualSize: number?,
	color: Color3?,
	hoverColor: Color3?,
}

return {}
