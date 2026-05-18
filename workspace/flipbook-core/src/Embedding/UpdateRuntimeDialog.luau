local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local embedIntoExperience = require("@root/Embedding/embedIntoExperience")
local enforceSingleRuntime = require("@root/Embedding/runtime/enforceSingleRuntime")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local e = React.createElement
local useCallback = React.useCallback
local useEffect = React.useEffect
local useState = React.useState

type RuntimeState = {
	instance: Instance?,
}

local function UpdateRuntimeDialog(): React.Node?
	local runtimeToUpdate, setRuntimeToUpdate = useState({
		instance = nil,
	} :: RuntimeState)

	useEffect(function()
		local existingRuntime = enforceSingleRuntime()
		if existingRuntime ~= nil then
			setRuntimeToUpdate({
				instance = existingRuntime,
			})
		end
	end, {})

	local onClose = useCallback(function()
		setRuntimeToUpdate({
			instance = nil,
		})
	end, {})

	local onUpdate = useCallback(function()
		if runtimeToUpdate.instance ~= nil then
			embedIntoExperience(runtimeToUpdate.instance)
		end

		setRuntimeToUpdate({
			instance = nil,
		})
	end, { runtimeToUpdate })

	if runtimeToUpdate.instance == nil then
		return nil
	end

	return e(Foundation.Dialog.Root, {
		disablePortal = false,
		hasBackdrop = true,
		onClose = onClose,
		onPressedOutside = onClose,
	}, {
		Title = e(Foundation.Dialog.Title, {
			text = "Update embedded Flipbook?",
		}),

		Content = e(Foundation.Dialog.Content, {
			LayoutOrder = nextLayoutOrder(),
		}, {
			Description = e(Foundation.Dialog.Text, {
				LayoutOrder = nextLayoutOrder(),
				tag = "auto-xy text-wrap text-body-medium",
				Text = `Saw an embedded Flipbook runtime at {runtimeToUpdate.instance:GetFullName()}. It may be out of date. Do you want to update it to this plugin version?`,
			}),
		}),

		Actions = e(Foundation.Dialog.Actions, {
			LayoutOrder = nextLayoutOrder(),
			actions = {
				{
					text = "Not now",
					onActivated = onClose,
				},
				{
					text = "Update",
					variant = Foundation.Enums.ButtonVariant.Emphasis,
					onActivated = onUpdate,
				},
			},
		}),
	})
end

return UpdateRuntimeDialog
