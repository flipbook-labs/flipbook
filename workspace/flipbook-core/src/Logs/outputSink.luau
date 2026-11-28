local Archivist = require("@pkg/Archivist")

--[[
	The sink that writes Flipbook's logs to Studio Output, with each line
	prefixed by its logger's name. There is one shared instance, so the logger
	can tell whether it's already attached.
]]
return Archivist.createConsoleSink({
	formatter = Archivist.createPrettyFormatter({
		middleware = {
			Archivist.middleware.name,
		},
	}),
})
