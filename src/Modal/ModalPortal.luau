local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ModalContext = require("@root/Modal/ModalContext")

export type Props = {
	children: React.Node?,
}

local function ModalPortal(props: Props)
	local modalContext = ModalContext.use()

	return if modalContext.target then ReactRoblox.createPortal(props.children, modalContext.target) else nil
end

return ModalPortal
