local React = require("@pkg/React")

local createFlipbookStore = require("@root/FlipbookStore/createFlipbookStore")

type FlipbookStore = createFlipbookStore.FlipbookStore

local Context = React.createContext(nil :: FlipbookStore?)

export type Props = {
	store: FlipbookStore,
	children: React.Node?,
}

local function Provider(props: Props)
	return React.createElement(Context.Provider, {
		value = props.store,
	}, props.children)
end

local function useFlipbookStore(): FlipbookStore
	local store = React.useContext(Context)
	assert(store ~= nil, "useFlipbookStore must be used within a FlipbookStore provider")
	return store
end

return {
	Provider = Provider,
	use = useFlipbookStore,
}
