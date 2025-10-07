-- upstream: https://github.com/sindresorhus/split-on-first/blob/v1.1.0/index.js
--[[
MIT License

Copyright (c) Sindre Sorhus <sindresorhus@gmail.com> (sindresorhus.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local function TypeError(message)
	return message
end

local function splitOnFirst(string, separator)
	if not (type(string) == "string" and type(separator) == "string") then
		error(TypeError("Expected the arguments to be of type `string`"))
	end

	if separator == "" then
		return { string }
	end

	local separatorIndex = string:find(separator, 1, true)

	if separatorIndex == nil then
		return { string }
	end

	return {
		string:sub(1, separatorIndex - 1),
		string:sub(separatorIndex + separator:len()),
	}
end

return splitOnFirst
