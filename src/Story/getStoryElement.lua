--[[
    Given a Story, this function will return a React element.

    A story can either be the result of React.createElement(), or a component
    that accepts props containing the `controls` table.

    As an element:

    ```lua
    return {
        story = React.createElement("TextLabel", {
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
            return React.createElement("TextLabel", {
                Text = props.controls.body
            })
        end
    }
    ```
]]

local types = require(script.Parent.Parent.types)

local function getStoryElement(story: types.Story, controls: types.Controls)
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
