local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MarkdownContent = require("./MarkdownContent")
local MockPlugin = require("@root/Testing/MockPlugin")

local Docs = require("@workspace/docs/src")

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			MarkdownContent = React.createElement(MarkdownContent, {
				content = Docs["migration-guides"]["migrating-hoarcekat"].Value,
			}),
		})
	end,
}
