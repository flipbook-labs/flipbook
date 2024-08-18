local ModuleLoader = require("@pkg/ModuleLoader")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local loadStoryModule = require("@root/Storybook/loadStoryModule")
local storybookTypes = require("@root/Storybook/types")
local useStorybooks = require("@root/Storybook/useStorybooks")

local createContext = React.createContext
local useCallback = React.useCallback
local useContext = React.useContext
local useState = React.useState

type Story = storybookTypes.Story
type Storybook = storybookTypes.Storybook

export type StorytellerContext = {
	storybooks: { Storybook },
	activeStory: Story?,
	activeStorybook: Storybook?,

	setContainer: (container: Instance) -> (),

	openStory: (storyModule: ModuleScript, storybook: Storybook) -> (),
}

local StorytellerContext = createContext()

export type Props = {
	-- The location to search for descendant storybooks
	storybookRoot: Instance,

	-- An instance of ModuleLoader for loading storybooks and stories
	loader: any,
}

local defaultProps = {
	loader = ModuleLoader.new(),
}

type InternalProps = Props & typeof(defaultProps)

local function StorytellerProvider(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.join(defaultProps, providedProps)

	-- All storybooks are gathered and loaded right away, but stories do not
	-- receive the same treatment.  Reason being, we need the storybooks to
	-- discover where all the stories are so we can render them in the UI. But
	-- stories themselves are only useful to be rendered when the user selects
	-- one. This is why we often deal with ModuleScripts for stories directly
	local storybooks = useStorybooks(props.storybookRoot, props.loader)

	local container, setContainer = useState(nil :: Instance?)

	local currentStoryModule, setCurrentStoryModule = useState(nil :: ModuleScript?)

	local activePair, setActivePair = useState({
		story = nil :: Story?,
		storybook = nil :: Storybook?,
	})

	local openStory = useCallback(function(storyModule: ModuleScript, storybook: Storybook)
		local story, err = loadStoryModule(props.loader, storyModule, storybook)

		setActivePair({
			story = story,
			storybook = storybook,
		})
	end, { props.loader })

	return React.createElement(StorytellerContext.Provider, {
		value = {
			storybooks = storybooks,
			activeStory = activePair.story,
			activeStorybook = activePair.storybook,

			setContainer = setContainer,
			openStory = openStory,
		},
	})
end

local function useStorytellerContext(): StorytellerContext
	return useContext(StorytellerContext)
end

return {
	StorytellerContext = StorytellerContext,
	StorytellerProvider = StorytellerProvider,
	useStorytellerContext = useStorytellerContext,
}
