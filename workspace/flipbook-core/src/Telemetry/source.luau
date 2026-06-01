local Charm = require("@pkg/Charm")

export type Source = "plugin-widget" | "embedded-client"

local get, set = Charm.signal(nil :: Source?)

return {
	get = get,
	set = set,
}
