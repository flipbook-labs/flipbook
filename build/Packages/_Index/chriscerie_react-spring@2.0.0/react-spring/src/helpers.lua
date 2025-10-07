local util = require(script.Parent.util)

local helpers = {}

function helpers.getValuesFromType(data)
	local dataType = typeof(data)

	if dataType == "number" then
		return { data }
	elseif dataType == "UDim" then
		return { data.Scale, data.Offset }
	elseif dataType == "UDim2" then
		return { data.X.Scale, data.X.Offset, data.Y.Scale, data.Y.Offset }
	elseif dataType == "Vector2" then
		return { data.X, data.Y }
	elseif dataType == "Vector3" then
		return { data.X, data.Y, data.Z }
	elseif dataType == "Color3" then
		return { data.R, data.G, data.B }
	end

	error("Unsupported type: " .. dataType)
end

function helpers.getTypeFromValues(type: string, values: { number })
	if type == "number" then
		return values[1]
	elseif type == "UDim" then
		return UDim.new(values[1], values[2])
	elseif type == "UDim2" then
		return UDim2.new(values[1], values[2], values[3], values[4])
	elseif type == "Vector2" then
		return Vector2.new(values[1], values[2])
	elseif type == "Vector3" then
		return Vector3.new(values[1], values[2], values[3])
	elseif type == "Color3" then
		return Color3.new(values[1], values[2], values[3])
	end

	error("Unsupported type: " .. type)
end

local DEFAULT_PROPS = table.freeze({
	"config",
	"immediate",
})

local RESERVED_PROPS = table.freeze({
	config = 1,
	from = 1,
	to = 1,
	loop = 1,
	reset = 1,
	immediate = 1,
	default = 1,
	delay = 1,

	-- Internal props
	keys = 1,
})

function helpers.getDefaultProps(props)
	local defaults = {}
	for _, key in ipairs(DEFAULT_PROPS) do
		if props[key] then
			defaults[key] = props[key]
		end
	end
	return defaults
end

--[[
    Extract any properties whose keys are *not* reserved for customizing your
    animations
]]
local function getForwardProps(props)
	local forward = {}

	local count = 0
	for prop, value in pairs(props) do
		if not RESERVED_PROPS[prop] then
			forward[prop] = value
			count += 1
		end
	end

	if count > 0 then
		return forward
	end
end

-- Clone the given `props` and move all non-reserved props into the `to` prop
function helpers.inferTo(props)
	local to = getForwardProps(props)
	if to then
		local out = {
			to = to,
		}
		for key, value in pairs(props) do
			if not to[key] then
				out[key] = value
			end
		end
		return out
	end
	return table.clone(props)
end

-- Find keys with defined values
local function findDefined(values, keys: Array<string>)
	for key, value in pairs(values) do
		if value then
			if not table.find(keys, key) then
				table.insert(keys, key)
			end
		end
	end
end

--[[
    Return a new object based on the given `props`.

    All non-reserved props are moved into the `to` prop object.
    The `keys` prop is set to an array of affected keys, or `null` if all keys are affected.
]]
function helpers.createUpdate(props)
	props = helpers.inferTo(props)
	local to = props.to
	local from = props.from

	-- Collect the keys affected by this update
	local keys = {}

	if typeof(to) == "table" then
		findDefined(to, keys)
	end
	if typeof(from) == "table" then
		findDefined(from, keys)
	end

	props.keys = keys
	return props
end

function helpers.createLoopUpdate(props, loop)
	if loop == nil then
		loop = props.loop
	end

	local continueLoop = true
	if typeof(loop) == "function" then
		continueLoop = loop()
	end

	if continueLoop then
		local overrides = typeof(loop) == "table" and loop
		local reset = not overrides or overrides.reset

		local nextProps = table.clone(props)
		nextProps.loop = loop
		-- Avoid updating default props when looping
		nextProps.default = false
		-- Never loop the `pause` prop
		nextProps.pause = nil
		-- Ignore the "from" prop except on reset
		nextProps.from = reset and props.from
		nextProps.reset = reset
		if typeof(overrides) == "table" then
			nextProps = util.merge(nextProps, overrides)
		end

		return helpers.createUpdate(nextProps)
	end
end

return helpers
