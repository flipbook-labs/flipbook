--!strict

local React = require(script.Parent.Parent.React)
local Promise = require(script.Parent.Parent.Promise)
local Controller = require(script.Parent.Parent.Controller)
local util = require(script.Parent.Parent.util)
local common = require(script.Parent.Parent.types.common)
local isRoact17 = require(script.Parent.Parent.isRoact17)

local useRefKey = if isRoact17 then "current" else "value"

export type UseSpringsStylesList = { { [string]: common.ReactBinding } }

export type UseSpringsApi<T> = {
	start: (fn: (index: number) -> Controller.ControllerProps<T>) -> typeof(Promise.new()),
	stop: (keys: { string }?) -> nil,
	pause: (keys: { string }?) -> nil,
}

type UseSprings17Declarative = <T>(
	length: number,
	-- FIXME: doing `props: { Controller.ControllerProps<T> }` fails with inferred `to` props
	props: { T },
	deps: { unknown }?
) -> UseSpringsStylesList

type UseSprings17Imperative = <T>(
	length: number,
	props: (index: number) -> Controller.ControllerProps<T>,
	deps: { unknown }?
) -> (UseSpringsStylesList, UseSpringsApi<T>)

type UseSpringsLegacyRoactDeclarative = <T>(
	hooks: { [string]: any },
	length: number,
	-- FIXME: doing `props: { Controller.ControllerProps<T> }` fails with inferred `to` props
	props: { T },
	deps: { unknown }?
) -> UseSpringsStylesList

type UseSpringsLegacyRoactImperative = <T>(
	hooks: { [string]: any },
	length: number,
	props: (index: number) -> Controller.ControllerProps<T>,
	deps: { unknown }?
) -> (UseSpringsStylesList, UseSpringsApi<T>)

export type UseSprings =
	UseSprings17Declarative
	& UseSprings17Imperative
	& UseSpringsLegacyRoactDeclarative
	& UseSpringsLegacyRoactImperative

local function useSprings<T>(
	hooks: { [string]: any },
	length: number,
	props: { Controller.ControllerProps<T> } | (index: number) -> Controller.ControllerProps<T>,
	deps: { unknown }?
)
	local useRef: <T>(T) -> {
		current: T,
		value: T,
	} = hooks[if isRoact17 then "useRef" else "useValue"]

	local isImperative = useRef(nil :: boolean?)
	local ctrls = useRef({} :: {
		{
			[string]: Controller.ControllerApi,
		}
	})
	local UseSpringsStylesList = useRef({} :: UseSpringsStylesList)
	local apiList = useRef({} :: { { [string]: UseSpringsApi<common.AnimatableType> } })

	if typeof(props) == "table" then
		assert(
			isImperative[useRefKey] == nil or isImperative[useRefKey] == false,
			"useSprings detected a change from imperative to declarative. This is not supported."
		)
		isImperative[useRefKey] = false
	elseif typeof(props) == "function" then
		assert(
			isImperative[useRefKey] == nil or isImperative[useRefKey] == true,
			"useSprings detected a change from declarative to imperative. This is not supported."
		)
		isImperative[useRefKey] = true
	else
		error("Expected table or function for useSprings, got " .. typeof(props))
	end

	hooks.useEffect(function()
		if isImperative[useRefKey] == false and typeof(props) == "table" then
			for i, spring in ipairs(ctrls[useRefKey]) do
				local startProps = util.merge(props[i], {
					reset = if props[i].reset then props[i].reset else false,
				})
				spring:start(util.merge({ default = true }, startProps))
			end
		end
	end, deps)

	-- Create new controllers when "length" increases, and destroy
	-- the affected controllers when "length" decreases
	hooks.useMemo(function()
		if length > #ctrls[useRefKey] then
			for i = #ctrls[useRefKey] + 1, length do
				local styles, api = Controller.new(if typeof(props) == "table" then props[i] else props(i))
				ctrls[useRefKey][i] = api
				UseSpringsStylesList[useRefKey][i] = styles
			end
		else
			-- Clean up any unused controllers
			for i = length + 1, #ctrls[useRefKey] do
				ctrls[useRefKey][i]:stop()
				ctrls[useRefKey][i] = nil
				UseSpringsStylesList[useRefKey][i] = nil
				apiList[useRefKey][i] = nil
			end
		end
	end, { length })

	hooks.useMemo(function()
		if isImperative[useRefKey] then
			if #ctrls[useRefKey] > 0 then
				for apiName, value in pairs(getmetatable(ctrls[useRefKey][1])) do
					if typeof(value) == "function" and apiName ~= "new" then
						apiList[useRefKey][apiName] = function(apiProps: (index: number) -> any | any)
							local promises = {}
							for i, spring in ipairs(ctrls[useRefKey]) do
								table.insert(
									promises,
									Promise.new(function(resolve)
										local result = spring[apiName](
											spring,
											if typeof(apiProps) == "function" then apiProps(i) else apiProps
										)

										-- Some results might be promises
										if result and result.await then
											result:await()
										end

										resolve()
									end)
								)
							end

							return Promise.all(promises)
						end
					end
				end
			end
		end
		-- Need to pass {{}} because useMemo doesn't support nil dependency yet
	end, deps or { {} })

	-- Cancel the animations of all controllers on unmount
	hooks.useEffect(function()
		return function()
			for _, ctrl in ipairs(ctrls[useRefKey]) do
				ctrl:stop()
			end
		end
	end, {})

	if isImperative[useRefKey] then
		return UseSpringsStylesList[useRefKey], apiList[useRefKey]
	end

	return UseSpringsStylesList[useRefKey]
end

local exports: any = function(...)
	if isRoact17 then
		return useSprings(React, ...)
	end

	return useSprings(...)
end

local exportsTyped: UseSprings = exports

return exportsTyped
