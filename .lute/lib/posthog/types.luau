local json = require("@std/json")
local net = require("@std/net")

export type Request = {
	url: string,
	metadata: net.Metadata,
}

export type Event = {
	name: string,
	properties: { [string]: json.Value },
}

return nil
