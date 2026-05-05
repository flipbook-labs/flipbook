local Charm = require("@pkg/Charm")
local Storyteller = require("@pkg/Storyteller")

type StoryControlsSchema = Storyteller.StoryControlsSchema
type StoryControls = Storyteller.StoryControls

type StoryControlValue = Storyteller.StoryControlValue | { Storyteller.StoryControlValue }

export type StoryControlsStore = {
	setSchema: (schema: StoryControlsSchema?) -> (),
	getControlValue: (key: string) -> () -> StoryControlValue?,
	setControl: (key: string, value: StoryControlValue?) -> (),
	getControls: () -> StoryControls,
	clear: () -> (),
}

local function createStoryControlsStore(): StoryControlsStore
	local getSchema, setSchema = Charm.signal(nil :: StoryControlsSchema?)
	type ControlSignal = {
		get: () -> StoryControlValue?,
		set: (StoryControlValue?) -> (),
	}
	local signals: { [string]: ControlSignal } = {}
	local valueGetters: { [string]: () -> StoryControlValue? } = {}

	local function getDefaultForKey(key: string): StoryControlValue?
		local schema = getSchema()
		if schema == nil then
			return nil
		end
		local entry = schema[key]
		if typeof(entry) == "table" then
			return entry.default
		end
		return entry
	end

	local function ensureSignal(key: string): ControlSignal
		if signals[key] == nil then
			local get, set = Charm.signal(nil :: StoryControlValue?)
			signals[key] = { get = get, set = set }
		end
		return signals[key]
	end

	local function getControlValue(key: string): () -> StoryControlValue?
		if valueGetters[key] == nil then
			local signal = ensureSignal(key)
			valueGetters[key] = Charm.computed(function(): StoryControlValue?
				local override = signal.get()
				if override ~= nil then
					return override
				end
				return getDefaultForKey(key)
			end)
		end
		return valueGetters[key]
	end

	local function setControl(key: string, value: StoryControlValue?)
		ensureSignal(key)
		signals[key].set(value)
	end

	local getRawControls = Charm.computed(function()
		local result: StoryControls = {}
		local schema = getSchema()
		if schema ~= nil then
			for key in schema do
				local value = getControlValue(key)()
				if value ~= nil then
					result[key] = value
				end
			end
		end
		return result
	end)

	local getControls = Charm.computed(function()
		local schema = getSchema()
		local controls = getRawControls()
		if schema == nil then
			return controls
		end
		return Storyteller.hydrateControls(schema, controls)
	end)

	local function clear()
		for _, signal in signals do
			signal.set(nil)
		end
	end

	return {
		setSchema = setSchema,
		getControlValue = getControlValue,
		setControl = setControl,
		getControls = getControls,
		clear = clear,
	}
end

return {
	instance = createStoryControlsStore(),
	new = createStoryControlsStore,
}
