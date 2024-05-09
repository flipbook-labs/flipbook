local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local act = ReactRoblox.act

type Options = {
	wrapper: React.ComponentType<{
		children: React.ReactNode,
	}>,
}

local function renderHook<T...>(hook: () -> T..., options: Options?): () -> T...
	local result = React.createRef()

	local function TestComponent()
		result.current = table.pack(hook())
	end

	local container = Instance.new("Folder")
	local root = ReactRoblox.createRoot(container)

	local element = React.createElement(TestComponent)

	if options and options.wrapper then
		element = React.createElement(options.wrapper, nil, element)
	end

	act(function()
		root:render(element)
	end)

	return function()
		return table.unpack(result.current)
	end
end

return renderHook
