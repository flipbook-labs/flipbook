local Llama = require(script.Parent.Parent.Packages.Llama)
local getStoryElement = require(script.Parent.Parent.Modules.getStoryElement)
local enums = require(script.Parent.Parent.enums)
local types = require(script.Parent.Parent.types)
local usePrevious = require(script.Parent.usePrevious)

local function useStoryRenderer(hooks: any, story: types.Story, controls: { types.StoryControl }, parent: Instance)
	local prevStory = usePrevious(hooks, story)
	local err, setErr = hooks.useState(nil)
	local tree = hooks.useValue(nil)

	local unmount = hooks.useCallback(function()
		if tree.value and prevStory then
			if prevStory.format == enums.Format.Default then
				prevStory.roact.unmount(tree.value)
			elseif prevStory.format == enums.Format.Hoarcekat then
				local success, result = xpcall(function()
					return tree.value()
				end, debug.traceback)

				if not success then
					setErr(result)
				end
			end

			tree.value = nil
		end
	end, { prevStory, setErr })

	hooks.useEffect(function()
		unmount()

		if not (story and parent) then
			return
		end

		if story.format == enums.Format.Default then
			-- This ensures that the controls are always ready before mounting
			local initialControls = if Llama.isEmpty(controls) then story.controls else controls

			local element = getStoryElement(story, initialControls)

			local success, result = xpcall(function()
				tree.value = story.roact.mount(element, parent, story.name)
			end, debug.traceback)

			if success then
				if err then
					setErr(nil)
				end
			else
				if err ~= result then
					setErr(result)
				end
			end
		elseif story.format == enums.Format.Hoarcekat then
			local success, result = xpcall(function()
				tree.value = story.story(parent)
			end, debug.traceback)

			if success then
				if err then
					setErr(nil)
				end
			else
				if err ~= result then
					setErr(result)
				end
			end
		end
	end, { story, controls, unmount, parent, setErr })

	return err
end

return useStoryRenderer
