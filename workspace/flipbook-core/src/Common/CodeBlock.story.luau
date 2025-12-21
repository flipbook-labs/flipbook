local CodeBlock = require("./CodeBlock")
local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local FoundationProvider = Foundation.FoundationProvider

return {
	summary = "Previews a block of code",
	story = function()
		return React.createElement(FoundationProvider, nil, {
			CodeBlock = React.createElement(CodeBlock, {
				source = "local function add(a: number, b: number): number\n\treturn a + b\nend",
			}),
		})
	end,
}
