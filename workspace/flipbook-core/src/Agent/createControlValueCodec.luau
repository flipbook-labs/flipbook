local Storyteller = require("@pkg/Storyteller")

local getInstanceFromPath = require("@root/Common/getInstanceFromPath")
local getInstancePath = require("@root/Common/getInstancePath")

type AgentControls = { [string]: unknown }
type StoryControls = Storyteller.StoryControls
type StoryControlsSchema = Storyteller.StoryControlsSchema

export type ControlValueCodec = {
	decode: (controls: AgentControls) -> StoryControls,
	encode: (controls: StoryControls) -> AgentControls,
}

local LIST_CONTROL_TYPES = {
	Check = true,
	MultiSelect = true,
	Radio = true,
	Select = true,
}

local function fail(path: string, message: string): never
	error(`{path} {message}`, 0)
end

local function validateJsonValue(value: unknown, path: string, visiting: { [unknown]: boolean })
	local valueType = typeof(value)
	if valueType == "boolean" or valueType == "string" then
		return
	elseif valueType == "number" then
		local numberValue = value :: number
		if numberValue ~= numberValue or numberValue == math.huge or numberValue == -math.huge then
			fail(path, "must be a finite number")
		end
		return
	elseif valueType ~= "table" then
		fail(path, `is a {valueType}; values must use JSON primitives, arrays, or objects`)
	end

	local fields = value :: { [unknown]: unknown }
	if visiting[fields] then
		fail(path, "refers back to one of its ancestors")
	end
	visiting[fields] = true

	local count = 0
	local hasNumberKey = false
	local hasStringKey = false
	for key in fields do
		count += 1
		if type(key) == "string" then
			hasStringKey = true
		elseif type(key) == "number" and key >= 1 and key % 1 == 0 then
			hasNumberKey = true
		else
			visiting[fields] = nil
			fail(path, "has an invalid key; use strings or a contiguous 1..n array")
		end
	end

	if hasStringKey and hasNumberKey then
		visiting[fields] = nil
		fail(path, "mixes string and number keys")
	elseif hasNumberKey and count ~= #fields then
		visiting[fields] = nil
		fail(path, "is a sparse or non-contiguous array")
	end

	for key, child in fields do
		local childPath = if type(key) == "string" then `{path}.{key}` else `{path}[{key}]`
		validateJsonValue(child, childPath, visiting)
	end

	visiting[fields] = nil
end

local function getObject(value: unknown, path: string): { [string]: unknown }
	if typeof(value) ~= "table" then
		fail(path, "must be an encoded object")
	end

	local rawFields = value :: { [unknown]: unknown }
	local fields: { [string]: unknown } = {}
	for key, child in rawFields do
		if type(key) ~= "string" then
			fail(path, "must be an encoded object")
		end
		fields[key :: string] = child
	end
	return fields
end

local function expectFields(fields: { [string]: unknown }, path: string, expected: { [string]: boolean })
	for key in fields do
		if not expected[key] then
			fail(path, `contains unexpected field "{key}"`)
		end
	end
	for key in expected do
		if fields[key] == nil then
			fail(path, `is missing field "{key}"`)
		end
	end
end

local function isInDataModel(instance: Instance): boolean
	return instance == game or instance:IsDescendantOf(game)
end

local function encodeInstance(instance: Instance, path: string): { [string]: unknown }
	if not isInDataModel(instance) then
		fail(path, "is an Instance outside the current DataModel")
	end

	local instancePath = if instance == game then "" else getInstancePath(instance)
	local resolved = if instancePath == "" then game else getInstanceFromPath(instancePath)
	if resolved ~= instance then
		fail(path, "is an Instance whose path is ambiguous or cannot be resolved")
	end

	return {
		kind = "Instance",
		path = instancePath,
	}
end

local function encodeValue(value: unknown, path: string, visiting: { [unknown]: boolean }): unknown
	local valueType = typeof(value)
	if valueType == "boolean" or valueType == "string" then
		return value
	elseif valueType == "number" then
		validateJsonValue(value, path, {})
		return value
	elseif valueType == "Color3" then
		local color = value :: Color3
		return {
			kind = "Color3",
			r = color.R,
			g = color.G,
			b = color.B,
		}
	elseif valueType == "DateTime" then
		return {
			kind = "DateTime",
			unixTimestampMillis = (value :: DateTime).UnixTimestampMillis,
		}
	elseif valueType == "EnumItem" then
		local enumItem = value :: EnumItem
		return {
			kind = "EnumItem",
			enum = tostring(enumItem.EnumType),
			name = enumItem.Name,
		}
	elseif valueType == "Instance" then
		return encodeInstance(value :: Instance, path)
	elseif valueType ~= "table" then
		fail(path, `is a {valueType}, which is not a supported Story control value`)
	end

	local values = value :: { [unknown]: unknown }
	if visiting[values] then
		fail(path, "refers back to one of its ancestors")
	end
	visiting[values] = true

	local count = 0
	for key in values do
		if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
			visiting[values] = nil
			fail(path, "must be a contiguous 1..n array")
		end
		count += 1
	end
	if count ~= #values then
		visiting[values] = nil
		fail(path, "is a sparse or non-contiguous array")
	end

	local encoded = {}
	for index = 1, #values do
		encoded[index] = encodeValue(values[index], `{path}[{index}]`, visiting)
	end
	visiting[values] = nil
	return encoded
end

local function jsonValuesEqual(left: unknown, right: unknown): boolean
	if typeof(left) ~= typeof(right) then
		return false
	elseif typeof(left) ~= "table" then
		return left == right
	end

	local leftFields = left :: { [unknown]: unknown }
	local rightFields = right :: { [unknown]: unknown }
	local count = 0
	for key, value in leftFields do
		count += 1
		if not jsonValuesEqual(value, rightFields[key]) then
			return false
		end
	end

	local rightCount = 0
	for _ in rightFields do
		rightCount += 1
	end
	return count == rightCount
end

local function decodeColor(value: unknown, path: string): Color3
	local fields = getObject(value, path)
	expectFields(fields, path, { kind = true, r = true, g = true, b = true })
	if fields.kind ~= "Color3" then
		fail(path, 'must have kind "Color3"')
	end

	local r = fields.r
	local g = fields.g
	local b = fields.b
	if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
		fail(path, "must contain numeric r, g, and b fields")
	end
	local red = r :: number
	local green = g :: number
	local blue = b :: number
	if red < 0 or red > 1 or green < 0 or green > 1 or blue < 0 or blue > 1 then
		fail(path, "must contain r, g, and b values between 0 and 1")
	end
	return Color3.new(red, green, blue)
end

local function decodeDateTime(value: unknown, path: string): DateTime
	local fields = getObject(value, path)
	expectFields(fields, path, { kind = true, unixTimestampMillis = true })
	if fields.kind ~= "DateTime" then
		fail(path, 'must have kind "DateTime"')
	end

	local unixTimestampMillis = fields.unixTimestampMillis
	if type(unixTimestampMillis) ~= "number" or unixTimestampMillis % 1 ~= 0 then
		fail(path, "must contain an integer unixTimestampMillis")
	end
	local ok, result = pcall(DateTime.fromUnixTimestampMillis, unixTimestampMillis :: number)
	if not ok or typeof(result) ~= "DateTime" then
		fail(path, "contains an invalid unixTimestampMillis")
	end
	return result :: DateTime
end

local function decodeInstance(value: unknown, path: string): Instance
	local fields = getObject(value, path)
	expectFields(fields, path, { kind = true, path = true })
	if fields.kind ~= "Instance" then
		fail(path, 'must have kind "Instance"')
	end

	local instancePath = fields.path
	if type(instancePath) ~= "string" then
		fail(path, "must contain a string path")
	end
	local resolvedPath = instancePath :: string
	local instance = if resolvedPath == "" then game else getInstanceFromPath(resolvedPath)
	if instance == nil then
		fail(path, `references missing Instance "{resolvedPath}"`)
	end
	if not isInDataModel(instance) then
		fail(path, "references an Instance outside the current DataModel")
	end
	if instance ~= game and getInstancePath(instance) ~= resolvedPath then
		fail(path, "contains a non-canonical Instance path")
	end
	return instance
end

local function decodePrimitive(value: unknown, expectedType: string, path: string): unknown
	if typeof(value) ~= expectedType then
		fail(path, `must be a {expectedType}`)
	end
	return value
end

local function decodeDeclaredItem(value: unknown, items: { unknown }, path: string): unknown
	for index, item in items do
		local encodedItem = encodeValue(item, `{path} (declared item {index})`, {})
		if jsonValuesEqual(value, encodedItem) then
			return item
		end
	end
	return fail(path, "does not match any item declared by this control")
end

local function decodeListValue(value: unknown, items: { unknown }, path: string, expectsArray: boolean): unknown
	if not expectsArray then
		return decodeDeclaredItem(value, items, path)
	end
	if typeof(value) ~= "table" then
		fail(path, "must be an array of declared control items")
	end

	local rawValues = value :: { [unknown]: unknown }
	for key in rawValues do
		if type(key) ~= "number" then
			fail(path, "must be an array of declared control items")
		end
	end
	local decoded = {}
	for index = 1, #rawValues do
		decoded[index] = decodeDeclaredItem(rawValues[index], items, `{path}[{index}]`)
	end
	return decoded
end

local function decodeValue(value: unknown, definition: unknown, path: string): unknown
	if typeof(definition) ~= "table" then
		local expectedType = typeof(definition)
		if expectedType == "Color3" then
			return decodeColor(value, path)
		elseif expectedType == "DateTime" then
			return decodeDateTime(value, path)
		elseif expectedType == "Instance" then
			return decodeInstance(value, path)
		elseif expectedType == "EnumItem" then
			return decodeDeclaredItem(value, { definition }, path)
		end
		return decodePrimitive(value, expectedType, path)
	end

	local control = definition :: { [string]: unknown }
	local controlType = control.type
	if type(controlType) ~= "string" then
		fail(path, "has an invalid Story control definition")
	elseif controlType == "Boolean" then
		return decodePrimitive(value, "boolean", path)
	elseif controlType == "Number" or controlType == "Slider" then
		return decodePrimitive(value, "number", path)
	elseif controlType == "String" then
		return decodePrimitive(value, "string", path)
	elseif controlType == "Color" then
		return decodeColor(value, path)
	elseif controlType == "Date" then
		return decodeDateTime(value, path)
	elseif controlType == "Object" then
		return decodeInstance(value, path)
	elseif LIST_CONTROL_TYPES[controlType] then
		local rawItems = control.items
		if typeof(rawItems) ~= "table" then
			fail(path, "has a list control without declared items")
		end
		local items: { unknown } = {}
		for index, item in rawItems :: { [unknown]: unknown } do
			if type(index) ~= "number" then
				fail(path, "has a list control with invalid declared items")
			end
			items[index :: number] = item
		end
		return decodeListValue(value, items, path, controlType == "Check" or controlType == "MultiSelect")
	end
	return fail(path, `uses unsupported Story control type "{controlType}"`)
end

local function createControlValueCodec(schema: StoryControlsSchema): ControlValueCodec
	local function encode(controls: StoryControls): AgentControls
		local encoded: AgentControls = {}
		for name, value in controls do
			if schema[name] == nil then
				fail(`controls.{name}`, "is not declared by the mounted Story")
			end
			encoded[name] = encodeValue(value, `controls.{name}`, {})
		end
		return encoded
	end

	local function decode(controls: AgentControls): StoryControls
		validateJsonValue(controls, "controls", {})
		local decoded: StoryControls = {}
		for name, value in controls do
			if type(name) ~= "string" then
				fail("controls", "must use string control names")
			end
			local definition = schema[name]
			if definition == nil then
				fail(`controls.{name}`, "is not declared by the mounted Story")
			end
			decoded[name] = decodeValue(value, definition, `controls.{name}`) :: Storyteller.StoryControlValue
		end
		return decoded
	end

	return {
		decode = decode,
		encode = encode,
	}
end

return createControlValueCodec
