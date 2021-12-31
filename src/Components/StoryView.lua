local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local types = require(script.Parent.Parent.types)
local styles = require(script.Parent.Parent.styles)

type Props = {
	story: types.Story,
}

local function StoryView(props: Props, hooks: any)
	return Roact.createElement("ScrollingFrame", styles.ScrollingFrame, {
		Meta = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Summary = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.2),
			}),

			Controls = props.story.controls and Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.3),
			}),
		}),

		Preview = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
		}),
	})
end

return RoactHooks.new(Roact)(StoryView)
