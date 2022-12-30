--[[
    Given a Story, this function will return a Roact element.

    A story can either be the result of Roact.createElement(), or a component
    that accepts props containing the `controls` table.

    As an element:

    ```lua
    return {
        story = Roact.createElement("TextLabel", {
            Text = "Hello, World!"
        })
    }
    ```

    As a component:

    ```lua
    return {
        controls = {
            body = "Hello, World!"
        },
        story = function(props)
            return Roact.createElement("TextLabel", {
                Text = props.controls.body
            })
        end
    }
    ```
]]

local types = require(script.Parent.Parent.types)

local function getStoryElement(story: types.RoactStory, props: types.StoryProps)
	if typeof(story.story) == "function" then
		local success, result = pcall(function()
			return story.roact.createElement(story.story, props)
		end)

		return if success then result else nil
	else
		return story.story
	end
end

return getStoryElement
