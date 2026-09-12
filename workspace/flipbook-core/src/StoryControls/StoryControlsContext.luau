local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")

type StoryControlsStore = createStoryControlsStore.StoryControlsStore
type StoryControlsSchema = Storyteller.StoryControlsSchema

local StoryControlsContext = React.createContext(nil :: StoryControlsStore?)

local function useStoryControls(): StoryControlsStore
	local storyControls = React.useContext(StoryControlsContext)
	assert(storyControls ~= nil, "useStoryControls must be used within a StoryControlsProvider")
	return storyControls
end

export type StoryControlsProviderProps = {
	schema: StoryControlsSchema?,
	store: StoryControlsStore?,
	children: React.Node?,
}

local function StoryControlsProvider(props: StoryControlsProviderProps)
	local store = React.useMemo(function()
		if props.store ~= nil then
			return props.store
		end

		return createStoryControlsStore(props.schema)
	end, { props.store, props.schema } :: { unknown })

	return React.createElement(StoryControlsContext.Provider, {
		value = store,
	}, props.children)
end

return {
	StoryControlsContext = StoryControlsContext,
	StoryControlsProvider = StoryControlsProvider,
	useStoryControls = useStoryControls,
}
