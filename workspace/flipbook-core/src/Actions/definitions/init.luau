local types = require("@root/Actions/types")

local ListStories = require("@root/Actions/definitions/ListStories")
local NavigateTo = require("@root/Actions/definitions/NavigateTo")
local SelectStory = require("@root/Actions/definitions/SelectStory")
local ToggleWidget = require("@root/Actions/definitions/ToggleWidget")

local definitions: { types.Action } = {
	ToggleWidget,
	NavigateTo,
	SelectStory,
	ListStories,
}

return definitions
