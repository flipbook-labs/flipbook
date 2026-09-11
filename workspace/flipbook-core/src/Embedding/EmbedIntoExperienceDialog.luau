local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local InstancePicker = require("@root/Common/InstancePicker")
local constants = require("@root/constants")
local embedFlipbookRuntime = require("@root/Embedding/embedFlipbookRuntime")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local e = React.createElement
local useCallback = React.useCallback
local useState = React.useState

local DEFAULT_DESTINATION = ReplicatedStorage

export type Props = {
	onClose: () -> (),
}

type EmbedStep = "SelectDestination" | "ConfirmOverwrite" | "Success"

local EmbedStep = {
	SelectDestination = "SelectDestination" :: "SelectDestination",
	ConfirmOverwrite = "ConfirmOverwrite" :: "ConfirmOverwrite",
	Success = "Success" :: "Success",
}

local function getExistingRuntime()
	local existing = CollectionService:GetTagged(constants.FLIPBOOK_RUNTIME_TAG)
	if #existing > 0 then
		return existing[1]
	end
	return nil
end

local function EmbedIntoExperienceDialog(props: Props)
	local selectedDestination: Instance?, setSelectedDestination = useState(DEFAULT_DESTINATION :: Instance?)
	local step: EmbedStep, setStep = useState(EmbedStep.SelectDestination :: EmbedStep)

	local onEmbed = useCallback(function()
		if not selectedDestination then
			return
		end

		local existing = getExistingRuntime()
		if existing then
			setStep(EmbedStep.ConfirmOverwrite)
			return
		end

		local embeddedFlipbook = embedFlipbookRuntime(selectedDestination)

		Selection:Set({ embeddedFlipbook })

		setStep(EmbedStep.Success)
	end, { selectedDestination })

	local onOverwrite = useCallback(function()
		for _, existingRuntime in CollectionService:GetTagged(constants.FLIPBOOK_RUNTIME_TAG) do
			existingRuntime:Destroy()
		end

		onEmbed()
	end, { onEmbed })

	local content
	local actions

	if step == EmbedStep.SelectDestination then
		content = e(Foundation.View, {
			tag = "auto-xy col gap-large",
		}, {
			Description = e(Foundation.Dialog.Text, {
				LayoutOrder = nextLayoutOrder(),
				tag = "auto-xy text-wrap text-body-medium",
				Text = "Flipbook will clone its runtime into the experience. Select a destination from the Explorer to control where it gets parented.",
			}),

			Destination = e(Foundation.View, {
				LayoutOrder = nextLayoutOrder(),
				tag = "auto-y size-full-0",
			}, {
				InstancePicker = e(InstancePicker, {
					value = selectedDestination,
					onChanged = setSelectedDestination,
				}),
			}),
		})

		actions = {
			{
				text = "Cancel",
				onActivated = props.onClose,
			},
			{
				text = "Embed",
				variant = Foundation.Enums.ButtonVariant.Emphasis :: Foundation.ButtonVariant,
				onActivated = onEmbed,
			},
		}
	elseif step == EmbedStep.ConfirmOverwrite then
		local existingRuntime = getExistingRuntime()
		content = e(Foundation.View, {
			tag = "auto-xy col gap-large",
		}, {
			Description = e(Foundation.Dialog.Text, {
				tag = "auto-xy text-wrap text-body-medium",
				LayoutOrder = nextLayoutOrder(),
				Text = `The Flipbook runtime already exists at <b>{if existingRuntime
					then existingRuntime:GetFullName()
					else "(unknown)"}</b>. There can only be one at a time. Do you want to overwrite it?`,
			}),
		})

		actions = {
			{
				text = "Close",
				onActivated = props.onClose,
			},
			{
				text = "Overwrite",
				variant = Foundation.Enums.ButtonVariant.Emphasis,
				onActivated = onOverwrite,
			},
		}
	elseif step == EmbedStep.Success then
		content = e(Foundation.View, {
			tag = "auto-xy col gap-large",
		}, {
			Description = e(Foundation.Dialog.Text, {
				tag = "auto-xy text-wrap text-body-medium",
				LayoutOrder = nextLayoutOrder(),
				Text = "Flipbook has been successfully embedded. Play the experience to try it out!",
			}),
		})

		actions = {
			{
				text = "Done",
				variant = Foundation.Enums.ButtonVariant.Emphasis,
				onActivated = props.onClose,
			},
		}
	end

	return e(Foundation.Dialog.Root, {
		disablePortal = false,
		hasBackdrop = true,
		onClose = props.onClose,
		onPressedOutside = props.onClose,
	}, {
		Title = e(Foundation.Dialog.Title, {
			text = "Embed Flipbook into Experience",
		}),

		Content = e(Foundation.Dialog.Content, {
			LayoutOrder = nextLayoutOrder(),
		}, content),

		Actions = e(Foundation.Dialog.Actions, {
			LayoutOrder = nextLayoutOrder(),
			actions = actions,
		}),
	})
end

return EmbedIntoExperienceDialog
