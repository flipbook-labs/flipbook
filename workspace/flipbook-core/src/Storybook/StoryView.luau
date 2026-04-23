local Foundation = require("@rbxpkg/Foundation")
local LuauPolyfill = require("@pkg/LuauPolyfill")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Storyteller = require("@pkg/Storyteller")

local PluginStore = require("@root/Plugin/PluginStore")
local StoryControls = require("@root/Storybook/StoryControls")
local StoryError = require("@root/Storybook/StoryError")
local StoryPreview = require("@root/Storybook/StoryPreview")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local types = require("@root/Storybook/types")
local useThemeName = require("@root/Common/useThemeName")

local Divider = Foundation.Divider
local Text = Foundation.Text
local View = Foundation.View

local Object = LuauPolyfill.Object

local e = React.createElement
local useCallback = React.useCallback
local useEffect = React.useEffect
local useMemo = React.useMemo
local useState = React.useState
local useSignalState = ReactCharm.useSignalState
local useStory = Storyteller.useStory
local useOverlay = Foundation.Hooks.useOverlay

type LoadedStorybook = Storyteller.LoadedStorybook
type ExtraStoryProps = types.ExtraStoryProps

type StoryViewProps = {
	storyModule: ModuleScript,
	storybook: LoadedStorybook,
}

local function StoryView(props: StoryViewProps)
	local story, storyError = useStory(props.storyModule, props.storybook)
	local theme = useThemeName()
	local pluginStore = useSignalState(PluginStore.get)
	local plugin = useSignalState(pluginStore.getPlugin)
	local overlayGui = useOverlay()

	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local modifiedControls, setModifiedControls = useState({})
	local controls = useMemo(function()
		local newControls = {}

		if story ~= nil and story.controls ~= nil then
			for key, value in story.controls do
				if modifiedControls[key] ~= nil and typeof(value) ~= "table" then
					newControls[key] = modifiedControls[key]
				else
					if typeof(value) == "table" then
						newControls[key] = value.default
					else
						newControls[key] = value
					end
				end
			end
		end

		return newControls
	end, { story, modifiedControls } :: { any })

	local extraProps = useMemo(function(): ExtraStoryProps
		return {
			theme = theme :: useThemeName.ThemeName,
			locale = userSettings.locale,
			plugin = plugin,
			widget = overlayGui,
		}
	end, { theme, plugin, overlayGui, userSettings.locale } :: { unknown })

	local setControl = useCallback(function(key: string, value: any)
		setModifiedControls(function(currentValue)
			return Object.assign({}, currentValue, {
				[key] = value,
			})
		end)
	end, {})

	useEffect(function()
		setModifiedControls({})
	end, { story })

	return e(View, {
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
					controls = controls,
					extraProps = extraProps,
				}),
			}),

			Controls = next(controls) ~= nil and e(StoryControls, {
				LayoutOrder = 4,
				controls = controls,
				modifiedControls = modifiedControls,
				setControl = setControl,
			}),
		}),
	})
end

return React.memo(StoryView)
