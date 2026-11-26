local React = require("@pkg/React")

local StoryProblemNotice = require("@root/Storybook/StoryProblemNotice")

-- Long enough that the error scrolls inside the notice.
local PROBLEM = table.concat({
	"Failed to load story ReplicatedStorage.Components.Button.story.",
	"Error: ReplicatedStorage.Components.ButtonStyles:12: attempt to index nil with 'Padding'",
	"ReplicatedStorage.Components.ButtonStyles:12",
	"ReplicatedStorage.Components.ButtonStyles:8 function getStyles",
	"ReplicatedStorage.Components.Button:21 function Button",
	"ReplicatedStorage.Components.Button.story:5",
	"ReplicatedStorage.Packages.ModuleLoader:162 function require",
	"ReplicatedStorage.Packages.ModuleLoader:118",
	"ReplicatedStorage.Packages.Storyteller.loadStoryModuleData:226",
	"ReplicatedStorage.Packages.Storyteller.stores.StoryModuleRecordStore:371 function createRecord",
	"ReplicatedStorage.Packages.Storyteller.stores.StoryModuleRecordStore:440",
}, "\n")

return {
	summary = "Shown above a Story when its latest edit fails to load",
	story = function()
		return React.createElement(StoryProblemNotice, {
			problem = PROBLEM,
		})
	end,
}
