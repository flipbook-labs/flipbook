local React = require("@pkg/React")

local ModalContext = require("@root/Modal/ModalContext")

local function ModalRoot()
	local modalContext = ModalContext.use()

	return React.createElement("Folder", {
		[React.Tag] = modalContext.tag,
	}, modalContext.modalContent)
end

return ModalRoot
