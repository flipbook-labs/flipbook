local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)
local Sift = require(script.Parent.Parent.Packages.Sift)
local SignalsReact = require(script.Parent.Parent.RobloxPackages.SignalsReact)

local UserSettingsStore = require(script.Parent.Parent.UserSettings.UserSettingsStore)
local nextLayoutOrder = require(script.Parent.Parent.Common.nextLayoutOrder)

local e = React.createElement

local noop = function() end

local useSignalState = SignalsReact.useSignalState
local useCallback = React.useCallback

type Props = {
	layoutOrder: number?,
	onPreviewInViewport: (() -> ())?,
	onZoomIn: (() -> ())?,
	onZoomOut: (() -> ())?,
	onViewCode: (() -> ())?,
	onExplorer: (() -> ())?,
}

local function StoryViewNavbar(props: Props)
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local onThemeChanged = useCallback(function(itemId: string | number)
		userSettingsStore.setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				theme = itemId,
			})
		end)
	end, { userSettingsStore.setStorage })

	return e(Foundation.View, {
		tag = "size-full-0 auto-y row gap-small align-y-center",
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

		ThemeSelection = e(Foundation.Dropdown.Root, {
			size = Foundation.Enums.InputSize.Small,
			label = "",
			onItemChanged = onThemeChanged,
			width = UDim.new(0, 150),
			value = userSettings.theme,
			items = {
				{
					id = "system",
					text = "System",
				},
				{
					id = "dark",
					text = "Dark",
				},
				{
					id = "light",
					text = "Light",
				},
			},
			LayoutOrder = nextLayoutOrder(),
		}),
	})
end

return StoryViewNavbar
