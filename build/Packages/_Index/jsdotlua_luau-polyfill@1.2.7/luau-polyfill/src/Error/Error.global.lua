local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))

type Function = types.Function

export type Error = { name: string, message: string, stack: string? }
type Error_private = Error & { __stack: string? }

local Error = {}

local DEFAULT_NAME = "Error"
Error.__index = Error
Error.__tostring = function(self)
	-- Luau FIXME: I can't cast to Error or Object here: Type 'Object' could not be converted into '{ @metatable *unknown*, {|  |} }'
	return getmetatable(Error :: any).__tostring(self)
end

-- ROBLOX NOTE: extracted __createError function so that both Error.new() and Error() can capture the stack trace at the same depth
local function __createError(message: string?): Error
	local self = (setmetatable({
		name = DEFAULT_NAME,
		message = message or "",
	}, Error) :: any) :: Error
	Error.__captureStackTrace(self, 4)
	return self
end

function Error.new(message: string?): Error
	return __createError(message)
end

function Error.captureStackTrace(err: Error, options: Function?)
	Error.__captureStackTrace(err, 3, options)
end

function Error.__captureStackTrace(err_: Error, level: number, options: Function?)
	local err = err_ :: Error_private
	if typeof(options) == "function" then
		local stack = debug.traceback(nil, level)
		local functionName: string = debug.info(options, "n")
		local sourceFilePath: string = debug.info(options, "s")

		local espacedSourceFilePath = string.gsub(sourceFilePath, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
		local stacktraceLinePattern = espacedSourceFilePath .. ":%d* function " .. functionName
		local beg = string.find(stack, stacktraceLinePattern)
		local end_ 		
if beg ~= nil then
			beg, end_ = string.find(stack, "\n", beg + 1)
		end
		if end_ ~= nil then
			stack = string.sub(stack, end_ + 1)
		end
		err.__stack = stack
	else
		err.__stack = debug.traceback(nil, level)
	end
	Error.__recalculateStacktrace(err)
end

function Error.__recalculateStacktrace(err_: Error)
	local err = err_ :: Error_private
	local message = err.message
	local name = err.name or DEFAULT_NAME

	local errName = name .. (if message ~= nil and message ~= "" then (": " .. message) else "")
	local stack = if err.__stack then err.__stack else ""

	err.stack = errName .. "\n" .. stack
end

return setmetatable(Error, {
	__call = function(_, ...)
		return __createError(...)
	end,
	__tostring = function(self)
		if self.name ~= nil then
			if self.message and self.message ~= "" then
				return string.format("%s: %s", tostring(self.name), tostring(self.message))
			end
			return tostring(self.name)
		end
		return tostring(DEFAULT_NAME)
	end,
})
