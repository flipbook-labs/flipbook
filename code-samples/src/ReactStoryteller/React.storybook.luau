local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local storybook: Storyteller.Storybook = {
	storyRoots = {
		script.Parent.Components,
	},
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}

return storybook
