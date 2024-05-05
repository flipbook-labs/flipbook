local enums = {}

export type Screen = "Home" | "Settings" | "About"
local Screen: { [string]: Screen } = {
	Home = "Home" :: "Home",
	Settings = "Settings" :: "Settings",
	About = "About" :: "About",
}
enums.Screen = Screen

return enums
