local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local StoryActionsContext = require("@root/Storybook/StoryActionsContext")
local StoryError = require("@root/Storybook/StoryError")
local StoryPreview = require("@root/Storybook/StoryPreview")
local Storyteller = require("@pkg/Storyteller")

local Divider = Foundation.Divider
local Text = Foundation.Text
local View = Foundation.View

local e = React.createElement

local useStory = Storyteller.useStory

type LoadedStorybook = Storyteller.LoadedStorybook

type StoryViewProps = {
	story: ModuleScript,
	storybook: LoadedStorybook,
}

local function StoryView(props: StoryViewProps)
	local storyActions = StoryActionsContext.useStoryActions()
	local storyData, storyError = useStory(props.story, props.storybook)

	return e(View, {
		tag = "size-full",
	}, {
		Error = storyError ~= nil and e(StoryError, {
			errorMessage = storyError,
		}),

		Story = storyData ~= nil and e(View, {
			tag = "col size-full",
		}, {
			Info = e(View, {
				LayoutOrder = 1,
				tag = "auto-y col gap-small padding-large size-full-0",
			}, {
				Title = e(Text, {
					LayoutOrder = 1,
					Text = storyData.name,
					tag = {
						-- NOTE (Paul): Super nitpick-y, but
						-- keeping all this on one line made
						-- for some really weird formatting
						-- that I couldn't accept.
						["auto-y content-emphasis size-full-0"] = true,
						["text-align-x-left text-align-y-top text-heading-large text-wrap"] = true,
					},
				}),

				Summary = storyData.summary ~= nil and e(Text, {
					LayoutOrder = 2,
					Text = storyData.summary,
					sizeConstraint = { MaxSize = Vector2.new(600, math.huge) },
					tag = "auto-y size-full-0 text-align-x-left text-align-y-top text-body-medium text-wrap",
				}),
			}),

			Divider = e(Divider, {
				LayoutOrder = 2,
			}),

			Preview = e(View, {
				LayoutOrder = 3,
				tag = "padding-large shrink size-full",
			}, {
				Preview = e(StoryPreview, {
					controls = {},
					isMountedInViewport = false,
					ref = storyActions.storyContainerRef,
					story = storyData,
					zoom = storyActions.zoom.value,
				}),
			}),
		}),
	})
end

return React.memo(StoryView)
