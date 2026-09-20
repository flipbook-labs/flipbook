local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Storyteller = require("@pkg/Storyteller")

local FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")
local PluginStore = require("@root/Plugin/PluginStore")
local StoryControlsContext = require("@root/StoryControls/StoryControlsContext")
local StoryControlsPanel = require("@root/StoryControls/StoryControlsPanel")
local StoryError = require("@root/Storybook/StoryError")
local StoryPreview = require("@root/Storybook/StoryPreview")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")
local types = require("@root/Storybook/types")
local useThemeName = require("@root/Common/useThemeName")

local Divider = Foundation.Divider
local Text = Foundation.Text
local View = Foundation.View

local e = React.createElement
local useEffect = React.useEffect
local useMemo = React.useMemo
local useSignalState = ReactCharm.useSignalState
local useStory = Storyteller.useStory
local useOverlay = Foundation.Hooks.useOverlay

type ExtraStoryProps = types.ExtraStoryProps

local function StoryView()
	local flipbookStore = FlipbookStoreContext.use()
	local selectedStory = useSignalState(flipbookStore.story.getSelectedStory)
	assert(selectedStory ~= nil, "StoryView requires an active story selection")

	local story, storyError = useStory(selectedStory.storyModule, selectedStory.storybook)
	local theme = useThemeName()
	local pluginStore = useSignalState(PluginStore.get)
	local plugin = useSignalState(pluginStore.getPlugin)
	local overlayGui = useOverlay()
	local controlsStore = useMemo(function()
		return createStoryControlsStore(if story then story.controls else nil)
	end, { story } :: { unknown })

	useEffect(function()
		flipbookStore.story.setActiveControlsStore(controlsStore)

		return function()
			if flipbookStore.story.getActiveControlsStore() == controlsStore then
				flipbookStore.story.setActiveControlsStore(nil)
			end
		end
	end, { controlsStore, flipbookStore } :: { unknown })

	local extraProps = useMemo(function(): ExtraStoryProps
		return {
			theme = theme :: useThemeName.ThemeName,
			locale = "en-us",
			plugin = plugin,
			widget = overlayGui,
		}
	end, { theme, plugin, overlayGui } :: { unknown })

	return e(
		StoryControlsContext.StoryControlsProvider,
		{
			store = controlsStore,
		},
		e(View, {
			tag = "size-full bg-surface-200",
		}, {
			Error = storyError ~= nil and e(StoryError, {
				errorMessage = storyError,
			}),

			Story = story ~= nil and e(View, {
				tag = "col size-full",
			}, {
				Info = e(View, {
					LayoutOrder = 1,
					tag = "auto-y col gap-small padding-large size-full-0",
				}, {
					Title = e(Text, {
						LayoutOrder = 1,
						Text = story.name,
						tag = {
							-- NOTE (Paul): Super nitpick-y, but keeping all this on
							-- one line made for some really weird formatting that I
							-- couldn't accept.
							["auto-y content-emphasis size-full-0"] = true,
							["text-align-x-left text-align-y-top text-heading-large text-wrap"] = true,
						},
					}),

					Summary = story.summary ~= nil and e(Text, {
						LayoutOrder = 2,
						Text = story.summary,
						sizeConstraint = { MaxSize = Vector2.new(600, math.huge) },
						tag = "auto-y size-full-0 text-align-x-left text-align-y-top text-body-medium text-wrap",
					}),
				}),

				Divider = e(Divider, {
					LayoutOrder = 2,
				}),

				Preview = e(View, {
					LayoutOrder = 3,
					tag = "shrink size-full",
				}, {
					StoryPreview = React.createElement(StoryPreview, {
						story = story,
						extraProps = extraProps,
					}),
				}),

				Controls = story.controls ~= nil and next(story.controls) ~= nil and e(StoryControlsPanel, {
					LayoutOrder = 4,
					controlsSchema = story.controls,
				}),
			}),
		})
	)
end

return React.memo(StoryView)
