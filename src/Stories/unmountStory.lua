local enums = require(script.Parent.Parent.enums)
local types = require(script.Parent.Parent.types)

local function unmountStory(story: types.Story, handle: any)
	if story.format == enums.Format.Default then
		story.roact.unmount(handle)
	elseif story.format == enums.Format.Hoarcekat then
		local success, result = xpcall(function()
			return handle()
		end, debug.traceback)

		if not success then
			warn(result)
		end
	end
end

return unmountStory
