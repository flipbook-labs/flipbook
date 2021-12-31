local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local styles = require(script.Parent.Parent.styles)
local useStory = require(script.Parent.Parent.Hooks.useStory)

type Props = {
	story: ModuleScript?,
}

local function StoryView(props: Props, hooks: any)
	-- local story = useStory(hooks, props.story)
	local story = useStory(hooks, script.Parent["Sample.story"])

	if not story then
		return
	end

	return Roact.createElement("ScrollingFrame", styles.ScrollingFrame, {
		Meta = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Summary = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.2),
			}),

			Controls = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.3),
			}),
		}),

		Preview = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
		}, {
			Story = story,
		}),
	})
end

return RoactHooks.new(Roact)(StoryView)
