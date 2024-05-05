local React = require("@pkg/React")

local RobloxProfile = require("@root/About/RobloxProfile")
local Sprite = require("@root/Common/Sprite")
local assets = require("@root/assets")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")
local wally = require(script.Parent.Parent["wally.toml"])

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

	local authors = {}
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
			Padding = theme.padding,
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
			Text = `flipbook`,
			TextColor3 = theme.text,
			TextSize = theme.headerTextSize,
			TextWrapped = true,
		}),

		Version = React.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.font,
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(0, 0),
			Text = `Version: {wally.package.version}`,
			TextColor3 = theme.text,
			TextSize = theme.textSize,
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
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = theme.paddingSmall,
			}),

			Icon = React.createElement(Sprite, {
				layoutOrder = nextLayoutOrder(),
				image = theme.githubIcon,
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
			}),

			Title = React.createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.font,
				LayoutOrder = nextLayoutOrder(),
				Size = UDim2.fromScale(0, 0),
				Text = `Authored by`,
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

		License = React.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.font,
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(0, 0),
			Text = `{wally.package.license} license`,
			TextColor3 = theme.text,
			TextSize = theme.textSize,
			TextWrapped = true,
		}),

		Copy = React.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.font,
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(0, 0),
			Text = `Copyright (c) {currentYear} flipbook-labs`,
			TextColor3 = theme.text,
			TextSize = theme.textSize,
			TextWrapped = true,
		}),
	})
end

return AboutView
