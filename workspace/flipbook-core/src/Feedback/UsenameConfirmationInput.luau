local Players = game:GetService("Players")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactUtils = require("@rbxpkg/ReactUtils")

local getClientUserId = require("@root/Common/getClientUserId")

local useState = React.useState
local useAsync = ReactUtils.useAsync

local function UsernameConfirmationInput(props: {
	LayoutOrder: number?,
})
	local username = useAsync(function()
		return Players:GetNameFromUserIdAsync(tonumber(getClientUserId()))
	end, {})

	local answer, setAnswer = useState("" :: string?)

	return React.createElement(Foundation.TextInput, {
		label = "Confirm Roblox username",
		text = answer,
		hasError = if answer ~= "" and username.status == "ok" then username.value:lower() ~= answer:lower() else nil,
		hint = "This form will be posted to GitHub, including your Roblox username to provide attribution. Please enter your Roblox username to confirm",
		placeholder = if username.status == "ok" then username.value else nil,
		isRequired = true,
		onChanged = setAnswer,
		LayoutOrder = props.LayoutOrder,
	})
end

return UsernameConfirmationInput
