local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local renderHook = require("./renderHook")

local test = JestGlobals.test
local expect = JestGlobals.expect

local act = ReactRoblox.act

test("works with useState", function()
	local getHookResult = renderHook(function()
		return React.useState(1)
	end)

	local state, setState = getHookResult()

	expect(state).toBe(1)

	act(function()
		setState(2)
	end)

	state, setState = getHookResult()

	expect(state).toBe(2)
end)

test("can supply a wrapper element", function()
	local context = React.createContext({})

	local function Provider(props): React.Node
		return React.createElement(context.Provider, {
			value = {
				isWrapped = true,
			},
		}, props.children)
	end

	local getHookResult = renderHook(function()
		return React.useContext(context)
	end, {
		wrapper = Provider,
	})

	local result = getHookResult()

	expect(result).toEqual({
		isWrapped = true,
	})
end)
