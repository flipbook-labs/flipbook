local React = require("@pkg/React")

local AppErrorFallback = require("@root/Common/AppErrorFallback")

return {
	summary = "Shown in place of Flipbook when an error escapes the app",
	story = function()
		local _, result = xpcall(function()
			error("Oops!")
		end, debug.traceback)

		return React.createElement(AppErrorFallback, {
			problem = result,
			onReload = function() end,
		})
	end,
}
