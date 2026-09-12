local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Storyteller = require("@pkg/Storyteller")

local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")

type StoryControlsStore = createStoryControlsStore.StoryControlsStore
type StoryControlsSchema = Storyteller.StoryControlsSchema
type StoryControls = Storyteller.StoryControls
type StoryControlValue = Storyteller.StoryControlValue | { Storyteller.StoryControlValue }

local StoryControlsContext = React.createContext(nil :: StoryControlsStore?)

local function useStoryControls(): StoryControlsStore
	local storyControls = React.useContext(StoryControlsContext)
	assert(storyControls ~= nil, "useStoryControls must be used within a StoryControlsProvider")
	return storyControls
end

local function useStoryControlValue(controlName: string): StoryControlValue?
	local storyControls = useStoryControls()
	return ReactCharm.useSignalState(
		storyControls.getControlValue(controlName),
		{ storyControls, controlName } :: { unknown }
	)
end

local function useStoryControlValues(): StoryControls
	local storyControls = useStoryControls()
	return ReactCharm.useSignalState(storyControls.getControls, { storyControls })
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
	useStoryControlValue = useStoryControlValue,
	useStoryControlValues = useStoryControlValues,
	useStoryControls = useStoryControls,
}
