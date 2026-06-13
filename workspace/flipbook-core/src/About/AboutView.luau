local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local BuildInfo = require("@root/About/BuildInfo")
local RobloxProfile = require("@root/About/RobloxProfile")
local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useColors = require("@root/Common/useColors")

local useTokens = Foundation.Hooks.useTokens
local useMemo = React.useMemo

local AUTHOR_USER_IDS = {
	1343930,
	731053179,
}

local function AboutView()
	local tokens = useTokens()
	local colors = useColors()
	local currentYear = useMemo(function()
		return (DateTime.now():ToUniversalTime() :: any).Year
	end, {})

	local authors: { [string]: React.Node } = {}
	for _, userId in AUTHOR_USER_IDS do
		authors[`Author{userId}`] = React.createElement(RobloxProfile, {
			userId = userId,
			LayoutOrder = nextLayoutOrder(),
		})
	end

	return React.createElement(Foundation.View, {
		tag = "size-full-0 auto-y col align-x-center gap-large padding-medium",
	}, {
		Logo = React.createElement(Foundation.Image, {
			Image = constants.FLIPBOOK_LOGO,
			Size = UDim2.fromOffset(tokens.Size.Size_1600, tokens.Size.Size_1600),
			LayoutOrder = nextLayoutOrder(),
		}),

		Title = React.createElement(Foundation.Text, {
			tag = "auto-xy text-heading-medium",
			LayoutOrder = nextLayoutOrder(),
			Text = `Flipbook {if _G.BUILD_VERSION then _G.BUILD_VERSION else "unreleased"}`,
		}),

		GitHub = React.createElement(Foundation.View, {
			tag = "auto-xy row gap-xsmall align-y-center",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Icon = React.createElement(Foundation.Image, {
				LayoutOrder = nextLayoutOrder(),
				Image = constants.GITHUB_LOGO,
				imageStyle = colors.github,
				Size = UDim2.fromOffset(tokens.Size.Size_400, tokens.Size.Size_400),
			}),

			Label = React.createElement(Foundation.Text, {
				tag = "auto-xy text-body-small",
				Text = "flipbook-labs/flipbook",
				LayoutOrder = nextLayoutOrder(),
			}),
		}),

		Authors = React.createElement(Foundation.View, {
			tag = "auto-xy col align-x-center gap-small",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Title = React.createElement(Foundation.Text, {
				tag = "auto-xy text-title-small",
				Text = `Created by:`,
				LayoutOrder = nextLayoutOrder(),
			}),

			AuthorList = React.createElement(Foundation.View, {
				tag = "auto-xy row align-x-center gap-small",
				LayoutOrder = nextLayoutOrder(),
			}, authors),
		}),

		BuildInfo = React.createElement(BuildInfo, {
			layoutOrder = nextLayoutOrder(),
		}),

		Copy = React.createElement(Foundation.Text, {
			tag = "auto-xy text-body-small",
			LayoutOrder = nextLayoutOrder(),
			Text = `Copyright © 2021—{currentYear} flipbook-labs`,
		}),
	})
end

return AboutView
