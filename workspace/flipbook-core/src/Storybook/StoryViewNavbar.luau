local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local e = React.createElement

local noop = function() end

type Props = {
	layoutOrder: number?,
	onPreviewInViewport: (() -> ())?,
	onZoomIn: (() -> ())?,
	onZoomOut: (() -> ())?,
	onViewCode: (() -> ())?,
	onExplorer: (() -> ())?,
}

local function StoryViewNavbar(props: Props)
	return e(Foundation.View, {
		tag = "size-full-0 auto-y row gap-small align-y-center padding-y-medium",
		LayoutOrder = props.layoutOrder,
	}, {
		Zoom = e(Foundation.View, {
			tag = "auto-xy row",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Magnify = e(Foundation.IconButton, {
				icon = Foundation.Enums.IconName.MagnifyingGlassPlus,
				onActivated = props.onZoomIn or noop,
				LayoutOrder = nextLayoutOrder(),
			}),

			Minify = e(Foundation.IconButton, {
				icon = Foundation.Enums.IconName.MagnifyingGlassMinus,
				onActivated = props.onZoomOut or noop,
				LayoutOrder = nextLayoutOrder(),
			}),
		}),

		-- Need to wrap the divider to constrain its height. Without this
		-- the divider will expand to the full height of the viewport
		VerticalDivider = e(Foundation.View, {
			tag = "size-0-800 auto-x",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Divider = e(Foundation.Divider, {
				orientation = Foundation.Enums.DividerOrientation.Vertical,
			}),
		}),

		Explorer = e(Foundation.Button, {
			text = "Explorer",
			size = Foundation.Enums.ButtonSize.Small,
			onActivated = props.onExplorer or noop,
			LayoutOrder = nextLayoutOrder(),
		}),

		ViewCode = e(Foundation.Button, {
			text = "View Code",
			size = Foundation.Enums.ButtonSize.Small,
			onActivated = props.onViewCode or noop,
			LayoutOrder = nextLayoutOrder(),
		}),

		PreviewInViewport = e(Foundation.Button, {
			text = "Preview in Viewport",
			size = Foundation.Enums.ButtonSize.Small,
			onActivated = props.onPreviewInViewport or noop,
			LayoutOrder = nextLayoutOrder(),
		}),
	})
end

return StoryViewNavbar
