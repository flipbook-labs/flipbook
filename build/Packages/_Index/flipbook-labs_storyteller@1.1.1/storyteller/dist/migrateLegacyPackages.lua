local isReact = require(script.Parent['roblox-internal'].isReact)
local types = require(script.Parent.types)

type StoryPackages = types.StoryPackages

local function migrateLegacyPackages(storyOrStorybook: { [string]: any }): StoryPackages?
	if storyOrStorybook.roact or storyOrStorybook.react or storyOrStorybook.reactRoblox then
		do -- Roblox internal. This behavior may be removed without notice.
			if storyOrStorybook.roact and storyOrStorybook.reactRoblox and isReact(storyOrStorybook.roact) then
				return {
					React = storyOrStorybook.roact,
					ReactRoblox = storyOrStorybook.reactRoblox,
				}
			end
		end

		return {
			Roact = storyOrStorybook.roact,
			React = storyOrStorybook.react,
			ReactRoblox = storyOrStorybook.reactRoblox,
		}
	end
	return nil
end

return migrateLegacyPackages
