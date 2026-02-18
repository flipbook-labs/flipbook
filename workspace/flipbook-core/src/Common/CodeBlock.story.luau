local React = require("@pkg/React")

local CodeBlock = require("./CodeBlock")

return {
	summary = "Previews a block of code",
	story = function()
		return React.createElement(CodeBlock, {
			source = "local function add(a: number, b: number): number\n\treturn a + b\nend",
		})
	end,
}
