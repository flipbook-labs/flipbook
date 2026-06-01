export type Source = "plugin-widget" | "embedded-client"

local current: Source? = nil

local function set(source: Source)
	current = source
end

local function get(): Source?
	return current
end

return {
	set = set,
	get = get,
}
