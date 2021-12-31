local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local Roact = require(script.Parent.Parent.Packages.Roact)

local function useStory(hooks: any, module: ModuleScript)
	local story, setStory = hooks.useState(nil)

	hooks.useEffect(function()
		if module then
			local loader = ModuleLoader.new()
			local result = loader:load(module)

			-- Something goes wrong with Roact components when they are loaded
			-- with ModuleLoader. Likely a problem with the symbols. Because of
			-- this, we create a brand new element based off the one given.
			local element = Roact.createElement(result.story.component, result.story.props)

			setStory(element)

			loader:clear()
		end
	end, { module })

	return story
end

return useStory
