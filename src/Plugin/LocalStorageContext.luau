local HttpService = game:GetService("HttpService")

local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local PluginContext = require("@root/Plugin/PluginContext")
local usePrevious = require("@root/Common/usePrevious")

local useCallback = React.useCallback
local useContext = React.useContext
local useEffect = React.useEffect
local useMemo = React.useMemo
local useState = React.useState

export type LocalStorage = {
	[string]: unknown,
}

export type LocalStorageContext = {
	get: (key: string) -> unknown,
	set: (key: string, value: unknown) -> (),
}

local LocalStorageContext = React.createContext(nil :: LocalStorageContext?)

export type Props = {
	storageKey: string,
	children: React.Node,
}

local function LocalStorageProvider(props: Props)
	local plugin = useContext(PluginContext.Context)

	local loadFromDisk = useCallback(function(): LocalStorage
		local data = plugin:GetSetting(props.storageKey)
		if data then
			local json = HttpService:JSONDecode(data)
			if json then
				return json
			end
		end
		return {}
	end, { plugin, props.storageKey } :: { unknown })

	local storage, setStorage = useState(loadFromDisk)
	local prevStorage = usePrevious(storage)

	local saveToDisk = useCallback(function()
		local data = HttpService:JSONEncode(storage)
		if data then
			plugin:SetSetting(props.storageKey, data)
		end
	end, { plugin, props.storageKey, storage } :: { unknown })

	local get = useCallback(function(key: string)
		return storage[key]
	end, { storage })

	local set = useCallback(function(key: string, value: any)
		setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				[key] = if typeof(value) == "function" then value(prev[key]) else value,
			})
		end)
	end, { storage })

	useEffect(function()
		if storage and storage ~= prevStorage then
			saveToDisk()
		end
	end, { storage, prevStorage, saveToDisk } :: { unknown })

	local context: LocalStorageContext = {
		get = get,
		set = set,
	}

	return React.createElement(LocalStorageContext.Provider, {
		value = context,
	}, props.children)
end

local function useLocalStorage(): LocalStorageContext
	local context = useContext(LocalStorageContext)
	if not context then
		local contextName = script.Name
		error(`failed to use {contextName}, is \`{contextName}.Provider\` defined in the React hierarchy?`)
	end
	return context
end

return {
	Provider = LocalStorageProvider,
	use = useLocalStorage,
}
