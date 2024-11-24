local React = require("@pkg/React")

local RobloxProfile = require("@root/About/RobloxProfile")
local BuildInfo = require("@root/About/BuildInfo")
local Sprite = require("@root/Common/Sprite")
local assets = require("@root/assets")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useMemo = React.useMemo

local AUTHOR_USER_IDS = {
	1343930,
	731053179,
}

local function AboutView()
	local theme = useTheme()
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

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.background,
		BorderSizePixel = 0,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = theme.paddingLarge,
		}),

		Padding = React.createElement("UIPadding", {
			PaddingTop = theme.paddingLarge,
			PaddingRight = theme.paddingLarge,
			PaddingBottom = theme.paddingLarge,
			PaddingLeft = theme.paddingLarge,
		}),

		Logo = React.createElement(Sprite, {
			layoutOrder = nextLayoutOrder(),
			image = assets.IconLight,
			size = UDim2.fromOffset(42, 42),
		}),

		Title = React.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.font,
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(0, 0),
			Text = `flipbook {if _G.BUILD_VERSION then _G.BUILD_VERSION else "unreleased"}`,
			TextColor3 = theme.text,
			TextSize = theme.headerTextSize,
			TextWrapped = true,
		}),

		GitHub = React.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = nextLayoutOrder(),
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = theme.paddingSmall,
			}),

			Icon = React.createElement(Sprite, {
				layoutOrder = nextLayoutOrder(),
				color = theme.github,
				image = assets.GitHubMark,
				size = UDim2.fromOffset(theme.textSize, theme.textSize),
			}),

			Label = React.createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.font,
				LayoutOrder = nextLayoutOrder(),
				Size = UDim2.fromScale(0, 0),
				Text = "flipbook-labs/flipbook",
				TextColor3 = theme.text,
				TextSize = theme.textSize,
			}),
		}),

		Authors = React.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = nextLayoutOrder(),
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = theme.padding,
			}),

			Title = React.createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.font,
				LayoutOrder = nextLayoutOrder(),
				Size = UDim2.fromScale(0, 0),
				Text = `Created by:`,
				TextColor3 = theme.text,
				TextSize = theme.textSize,
				TextWrapped = true,
			}),

			AuthorList = React.createElement("Frame", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = nextLayoutOrder(),
			}, {
				Layout = React.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = theme.padding,
				}),
			}, authors),
		}),

		BuildInfo = React.createElement(BuildInfo, {
			layoutOrder = nextLayoutOrder(),
		}),

		Copy = React.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.font,
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(0, 0),
			Text = `Copyright © 2021—{currentYear} flipbook-labs`,
			TextColor3 = theme.textSubtitle,
			TextSize = theme.textSize,
			TextWrapped = true,
		}),
	})
end

return AboutView
