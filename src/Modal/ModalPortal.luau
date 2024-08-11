local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ModalContext = require("@root/Modal/ModalContext")

export type Props = {
	children: React.Node?,
}

local function ModalPortal(props: Props)
	local modalContext = ModalContext.use()

	if modalContext.target then
		return ReactRoblox.createPortal(props.children, modalContext.target)
	else
		return nil
	end
end

return ModalPortal
