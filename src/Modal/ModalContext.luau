local React = require("@pkg/React")

local useTag = require("@root/Common/useTag")

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
	local target = useTag(MODAL_TAG)[1]

	return React.createElement(Context.Provider, {
		value = {
			tag = MODAL_TAG,
			target = target,
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
