local enums = {}

export type Screen = "Home" | "Settings" | "About" | "Logs"
enums.Screen = {
	Home = "Home" :: "Home",
	Settings = "Settings" :: "Settings",
	About = "About" :: "About",
	Logs = "Logs" :: "Logs",
}

return enums
