local React = require("@pkg/React")

local Panel = require("@root/Panel")
local PanelGroupContext = require("@root/PanelGroupContext")
local PanelSeparator = require("@root/PanelSeparator")
local types = require("@root/types")

export type GroupProps = {
	id: string,
	orientation: "horizontal" | "vertical",
	defaultLayout: types.LayoutSizes?,
	onLayoutChange: ((id: string, sizes: types.LayoutSizes) -> ())?,
	children: React.Node?,
}

local function isPanel(child: any): boolean
	return typeof(child) == "table" and child.type == Panel
end

local function Group(props: GroupProps)
	-- Collect Panel children and sort by LayoutOrder.
	-- Using pairs() directly works for both array-style and dictionary-style children,
	-- whereas React.Children.forEach only handles array-style (sequential integer key) tables.
	type PanelEntry = { child: any, layoutOrder: number, id: string }
	local panels: { PanelEntry } = {}
	local panelCount = 0

	if props.children ~= nil then
		for _, child in pairs(props.children :: any) do
			if isPanel(child) then
				panelCount += 1
				table.insert(panels, {
					child = child,
					layoutOrder = (child :: any).props.LayoutOrder or 0,
					id = (child :: any).props.id or tostring(panelCount),
				})
			end
		end
	end

	table.sort(panels, function(a, b)
		return a.layoutOrder < b.layoutOrder
	end)

	-- Build interleaved panel + separator children with contiguous LayoutOrders
	local children = {}
	for i, entry in ipairs(panels) do
		local panelLayoutOrder = i * 2 - 1 -- 1, 3, 5, ...
		children["p" .. i] = React.cloneElement(
			entry.child :: React.ReactElement<any, any>,
			{ id = entry.id, LayoutOrder = panelLayoutOrder }
		)

		if panels[i + 1] ~= nil then
			local sepLayoutOrder = i * 2 -- 2, 4, 6, ...
			children["s" .. i] = React.createElement(PanelSeparator, {
				LayoutOrder = sepLayoutOrder,
				beforeId = entry.id,
				afterId = panels[i + 1].id,
			})
		end
	end

	-- Pass non-Panel children through unchanged so they render inside the context.
	-- This allows things like context-reading components in tests to work correctly.
	if props.children ~= nil then
		for key, child in pairs(props.children :: any) do
			if not isPanel(child) then
				children[key] = child
			end
		end
	end

	return React.createElement(PanelGroupContext.Provider, {
		id = props.id,
		orientation = props.orientation,
		defaultLayout = props.defaultLayout,
		onLayoutChange = props.onLayoutChange,
	}, children :: any)
end

return Group
