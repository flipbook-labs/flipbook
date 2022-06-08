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

local flipbook = script:FindFirstAncestor("flipbook")

local types = require(flipbook.types)

local function getStoryElement(story: types.Story, controls: types.Controls?)
	controls = controls or story.controls

	if typeof(story.story) == "function" then
		local success, result = pcall(function()
			return story.story({
				controls = controls,
			})
		end)

		if success then
			return result
		end
	end

	return story.story
end

return getStoryElement
