--[[
	Router 2 — the agent door.

	Publishes a CoreGui folder containing one BindableFunction per action plus a
	`__manifest` Bindable for discovery. Each Bindable is tagged and carries its
	text/statusTip as attributes so an agent can introspect the registry without
	invoking anything.

	An agent (e.g. Studio Assistant's `execute_luau`) reaches this across the
	plugin/VM boundary by reading CoreGui and calling `:Invoke(payload)`. Results
	are always the `{ ok, result?, error? }` envelope from `dispatch`.

	Idempotent: any pre-existing folder is destroyed first, and the returned
	cleanup destroys the folder on unload.
]]

local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")

local constants = require("@root/Actions/constants")
local types = require("@root/Actions/types")

local function publishBindables(registry: types.ActionRegistry): () -> ()
	local existing = CoreGui:FindFirstChild(constants.FOLDER_NAME)
	if existing then
		existing:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = constants.FOLDER_NAME
	folder:SetAttribute("ProtocolVersion", constants.PROTOCOL_VERSION)

	for _, action in registry.actions do
		local bindable = Instance.new("BindableFunction")
		bindable.Name = action.id
		bindable:SetAttribute("Text", action.text)
		bindable:SetAttribute("StatusTip", action.statusTip)
		bindable.OnInvoke = function(payload)
			return registry.dispatch(action.id, payload)
		end
		CollectionService:AddTag(bindable, constants.TAG)
		bindable.Parent = folder
	end

	-- Discovery endpoint: returns the full manifest (ids + descriptions + params).
	local manifest = Instance.new("BindableFunction")
	manifest.Name = constants.MANIFEST_NAME
	manifest.OnInvoke = function()
		return registry.manifest()
	end
	manifest.Parent = folder

	folder.Parent = CoreGui

	return function()
		folder:Destroy()
	end
end

return publishBindables
