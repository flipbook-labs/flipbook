export type StoryStatus = "Loaded" | "Loading" | "Unavailable"

local StoryStatus = table.freeze({
	Loaded = "Loaded" :: "Loaded",
	Loading = "Loading" :: "Loading",
	Unavailable = "Unavailable" :: "Unavailable",
})

return StoryStatus
