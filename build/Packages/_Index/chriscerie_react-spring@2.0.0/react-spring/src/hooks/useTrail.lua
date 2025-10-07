--!strict
local React = require(script.Parent.Parent.React)
local Controller = require(script.Parent.Parent.Controller)
local useSprings = require(script.Parent.useSprings)
local util = require(script.Parent.Parent.util)
local isRoact17 = require(script.Parent.Parent.isRoact17)

local useRefKey = if isRoact17 then "current" else "value"

type UseTrailProps<T> = { Controller.ControllerProps<T> } | ((index: number) -> Controller.ControllerProps<T>)

local function useTrail<T>(hooks: { [string]: any }, length: number, props: UseTrailProps<T>, deps: { unknown }?)
	local mergedProps: UseTrailProps<T> = hooks.useMemo(function()
		if type(props) == "function" then
			return props
		else
			local newProps: { Controller.ControllerProps<T> } = table.create(length)
			local currentDelay = 0
			for i, v in ipairs(props) do
				local prop = util.merge({ delay = 0.1 }, v)
				local delayAmount = prop.delay
				prop.delay = currentDelay
				currentDelay += delayAmount
				newProps[i] = prop
			end

			-- Luau is not converting types correctly
			return newProps :: any
		end
		-- Need to pass {{}} because useMemo doesn't support nil dependency yet
	end, deps or { {} })

	-- TODO: Calculate delay for api methods as well
	local styles, api: useSprings.UseSpringsApi<T>?
	if isRoact17 then
		-- FIXME: Without any, type '(number) -> (T | {| from: T?, to: T? |}) & AnimationProps' could not be converted into '{a}'
		styles, api = useSprings(length, mergedProps :: any, deps)
	else
		styles, api = useSprings(hooks, length, mergedProps :: any, deps)
	end

	local modifiedApi = hooks[if isRoact17 then "useRef" else "useValue"]({})

	-- Return api with modified api.start
	if type(props) == "function" and api then
		-- We can't just copy as we want to guarantee the returned api doesn't change its reference
		table.clear(modifiedApi[useRefKey])
		for key, value in pairs(api) do
			modifiedApi[useRefKey][key] = value
		end

		modifiedApi[useRefKey].start = function(startFn)
			local currentDelay = 0
			return api.start(function(i)
				local startProps = util.merge({ delay = 0.1 }, startFn(i))
				local delayAmount = startProps.delay
				startProps.delay = currentDelay
				currentDelay += delayAmount
				return startProps
			end)
		end

		return styles, modifiedApi[useRefKey]
	end

	return styles
end

local exports: any = function(...)
	if isRoact17 then
		return useTrail(React, ...)
	end

	return useTrail(...)
end

local exportsTyped: useSprings.UseSprings = exports

return exportsTyped
