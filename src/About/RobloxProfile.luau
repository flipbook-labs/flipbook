local Players = game:GetService("Players")

local React = require("@pkg/react")
local ReactSpring = require("@pkg/react-spring")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useState = React.useState
local useEffect = React.useEffect

local AVATAR_SIZE = Enum.ThumbnailSize.Size48x48

export type Props = {
	userId: number,
	LayoutOrder: number?,
}

local function RobloxProfile(props: Props)
	local theme = useTheme()
	local avatar, setAvatar = useState(nil :: string?)
	local username, setUsername = useState(nil :: string?)

	local isLoading = avatar == nil and username == nil

	local styles = ReactSpring.useSpring({
		alpha = if isLoading then 1 else 0,
	})

	useEffect(function()
		task.spawn(function()
			setAvatar(Players:GetUserThumbnailAsync(props.userId, Enum.ThumbnailType.HeadShot, AVATAR_SIZE))
		end)

		task.spawn(function()
			setUsername(Players:GetNameFromUserIdAsync(props.userId))
		end)
	end, { props.userId })

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = theme.paddingSmall,
		}),

		Avatar = React.createElement("ImageLabel", {
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromOffset(48, 48),
			BackgroundColor3 = theme.sidebar,
			BackgroundTransparency = 0.6,
			ImageTransparency = styles.alpha,
			BorderSizePixel = 0,
			Image = avatar,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
		}),

		Username = React.createElement("TextLabel", {
			LayoutOrder = nextLayoutOrder(),
			Text = `@{username}`,
			Font = theme.font,
			TextColor3 = theme.text,
			TextSize = theme.textSize,
			BackgroundTransparency = 1,
			TextTransparency = styles.alpha,
			AutomaticSize = Enum.AutomaticSize.XY,
		}),
	})
end

return RobloxProfile
