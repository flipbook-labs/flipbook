local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")
local UILabs = require("@pkg/UILabs")

return {
	-- Example from: https://ui-labs.luau.page/docs/controls/advanced
	controls = {
		Theme = UILabs.Choose({ "Dark", "Light" }),
		Currency = UILabs.Choose({ "Coins", "Gems" }),

		WindowSize = UILabs.EnumList({
			Mobile = 500,
			Tablet = 1000,
			Desktop = 1500,
		}, "Mobile"),
		TextColor = UILabs.EnumList({
			Red = Color3.new(1, 0, 0),
			Green = Color3.new(0, 1, 0),
			Blue = Color3.new(0, 0, 1),
		}, "Red"),

		Group = UILabs.ControlGroup({
			Volume = UILabs.Slider(50, 0, 100, 1),
			FrameColor = UILabs.RGBA(Color3.new(1, 1, 1), 0),
		}),

		SelectedModule = UILabs.Advanced.Object("ModuleScript"),

		Greeting = UILabs.String("Hello, World!"),
	},
	story = function(props: Storyteller.StoryProps)
		local children: { [string]: React.Node } = {}

		for key, value in props.controls do
			children[key] = React.createElement(Foundation.Text, {
				tag = "auto-xy content-default text-body-large",
				Text = `- {key}: {value}`,
			})
		end

		return React.createElement(Foundation.View, {
			tag = "col gap-small",
		}, children)
	end,

	react = React,
	reactRoblox = ReactRoblox,
}
