local Foundation = require("@rbxpkg/Foundation")
local Markdown = require("@pkg/Markdown")
local React = require("@pkg/React")

export type Props = {
	content: string,
}

local function MarkdownContent(props: Props)
	local children: { [string]: React.Node } = {}

	for index, node in Markdown(props.content) do
		if node.name == "paragraph" then
			children[`{node.name}-{node.begin}`] = React.createElement(Foundation.Text, {
				tag = "size-full-0 auto-y text-wrap text-align-y-top text-align-x-left",
				LayoutOrder = index,
				Text = if typeof(node.value) == "string" then node.value else "",
			})
		end
	end

	return React.createElement(Foundation.View, {
		tag = "size-full-0 auto-y col gap-medium",
	}, children)
end

return MarkdownContent
