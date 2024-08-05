local React = require("@pkg/React")
local rendererTypes = require("@root/Renderers/types")
local storybookTypes = require("@root/Storybook/types")
local usePrevious = require("@root/Common/usePrevious")

local useEffect = React.useEffect
local useMemo = React.useMemo
local useState = React.useState

type Renderer = rendererTypes.Renderer
type Story = storybookTypes.Story
type Storybook = storybookTypes.Storybook

local function useStoryRenderer(renderer: Renderer, story: Story)
	local container, setContainer = useState(nil :: Instance?)

	local renderContext = useMemo(function()
		return {
			container = container,
			args = story.controls,
		}
	end, { container, story })

	local prevRenderContext = usePrevious(renderContext)

	useEffect(function()
		if not renderer.shouldUpdate or renderer.shouldUpdate(renderContext, prevRenderContext) then
			renderer.mount(container, story.story, renderContext)
		end

		return function()
			renderer.unmount()
		end
	end, { renderer, story, renderContext, prevRenderContext })

	return {
		setContainer = setContainer,
	}
end

return useStoryRenderer
