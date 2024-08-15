local React = require("@pkg/React")

local Branding = require("./Branding")
local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local stories = {}

stories.Primary = React.createElement(ContextProviders, {
	plugin = MockPlugin.new(),
}, {
	Branding = React.createElement(Branding),
})

return {
	summary = "Icon and Typography for flipbook",
	stories = stories,
}
