local enums = {}

export type Screen = "Home" | "Settings" | "About"
enums.Screen = {
	Home = "Home" :: Screen,
	Settings = "Settings" :: Screen,
	About = "About" :: Screen,
}

return enums
