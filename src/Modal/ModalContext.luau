local CollectionService = game:GetService("CollectionService")

local React = require("@pkg/React")

local useCallback = React.useCallback
local useContext = React.useContext

local MODAL_TAG = "modal-root"

local Context = React.createContext({})

export type ModalContext = {
	tag: string,
	close: () -> (),
	open: (element: React.Node) -> (),
}

export type Props = {
	children: any,
}

local function Provider(props: Props)
	local getModalRoot = useCallback(function()
		return CollectionService:GetTagged(MODAL_TAG)[1]
	end, {})

	local close = useCallback(function() end, {})

	local open = useCallback(function() end, {})

	return React.createElement(Context.Provider, {
		value = {
			tag = MODAL_TAG,
			close = close,
			open = open,
		},
	}, props.children)
end

local function use(): ModalContext
	return useContext(Context)
end

return {
	Context = Context,
	Provider = Provider,
	use = use,
}
