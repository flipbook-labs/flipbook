local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return {
	storyRoots = {
		script.Parent.Components,
	},
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
