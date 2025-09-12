local Sift = require("@pkg/Sift")
local Signals = require("@rbxpkg/Signals")

local HttpService = game:GetService("HttpService")

export type LocalStorage = {
	[string]: unknown,
}

export type LocalStorageStore = {
	get: (key: string) -> unknown,
	set: (key: string, value: unknown) -> (),
}

local function createPluginSettingsStore(plugin: Plugin, storageKey: string)
	local function loadFromDisk(): { [any]: any }?
		local data = plugin:GetSetting(storageKey)
		if typeof(data) == "table" then
			local json = HttpService:JSONDecode(data)
			if json then
				return json
			end
		end
		return data
	end

	local function saveToDisk(storage: LocalStorage)
		local data = HttpService:JSONEncode(getStorage(false))
		if data then
			plugin:SetSetting(storageKey, data)
		end
	end

	local getStorage, setStorage = Signals.createSignal({} :: LocalStorage)

	local function get(key: string)
		return getStorage(false)[key]
	end

	local function set(key: string, value: any)
		setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				[key] = if typeof(value) == "function" then value(prev[key]) else value,
			})
		end)
	end

	local dispose = Signals.createEffect(function(scope) end)

	useEffect(function()
		if storage and storage ~= prevStorage then
			saveToDisk()
		end
	end, { storage, prevStorage, saveToDisk } :: { unknown })

	return {
		get = get,
		set = set,
	}
end

return createPluginSettingsStore
