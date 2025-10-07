local Players = game:GetService("Players")

local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)
local ReactSpring = require(script.Parent.Parent.Packages.ReactSpring)

local nextLayoutOrder = require(script.Parent.Parent.Common.nextLayoutOrder)

local useState = React.useState
local useEffect = React.useEffect
local useTokens = Foundation.Hooks.useTokens

export type Props = {
	userId: number,
	LayoutOrder: number?,
}

local function RobloxProfile(props: Props)
	local tokens = useTokens()

	local username, setUsername = useState(nil :: string?)

	local isLoading = username == nil

	local styles = ReactSpring.useSpring({
		alpha = if isLoading then 1 else 0,
	})

	useEffect(function()
		task.spawn(function()
			setUsername(Players:GetNameFromUserIdAsync(props.userId))
		end)
	end, { props.userId })

	return React.createElement(Foundation.View, {
		tag = "auto-xy row align-y-center gap-small",
		LayoutOrder = props.LayoutOrder,
	}, {
		Avatar = React.createElement(Foundation.Avatar, {
			userId = props.userId,
			backplateStyle = tokens.Color.Surface.Surface_300,
			LayoutOrder = nextLayoutOrder(),
		}),

		Username = React.createElement(Foundation.Text, {
			tag = "auto-xy text-label-medium",
			LayoutOrder = nextLayoutOrder(),
			Text = `@{username}`,
			TextTransparency = styles.alpha,
		}),
	})
end

return RobloxProfile
