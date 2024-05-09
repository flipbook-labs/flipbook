local React = require("@pkg/React")
local Button = require("./Button")
local FlipbookReact = require("@pkg/flipbook-react")
type StoryObj = FlipbookReact.StoryObj

local stories: { [string]: StoryObj } = {}

stories.Primary = React.createElement(Button, {})

return {
	name = "Button",
	component = Button,
	stories = stories,
}
