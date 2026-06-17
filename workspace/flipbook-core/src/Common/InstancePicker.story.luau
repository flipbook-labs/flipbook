local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local InstancePicker = require("./InstancePicker")

local useState = React.useState

return {
	summary = "Lets users pick an Instance from the current Selection",
	story = function()
		local value, setValue = useState(nil :: Instance?)

		return React.createElement(Foundation.View, {
			tag = "size-full-0 auto-y col gap-large",
			sizeConstraint = {
				MaxSize = Vector2.new(300, math.huge),
			},
		}, {
			InstancePicker = React.createElement(InstancePicker, {
				value = value,
				onChanged = setValue,
			}),

			WithSelectedInstance = React.createElement(InstancePicker, {
				value = workspace,
			}),
		})
	end,
}
