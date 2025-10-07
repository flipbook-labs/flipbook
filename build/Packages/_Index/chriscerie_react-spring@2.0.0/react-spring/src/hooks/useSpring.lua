--!strict
local Promise = require(script.Parent.Parent.Promise)
local Controller = require(script.Parent.Parent.Controller)
local common = require(script.Parent.Parent.types.common)
local useSprings = require(script.Parent.useSprings)
local isRoact17 = require(script.Parent.Parent.isRoact17)

export type UseSpringApi<T> = {
	start: (startProps: Controller.ControllerProps<T>) -> typeof(Promise.new()),
	stop: (keys: { string }?) -> nil,
	pause: (keys: { string }?) -> nil,
}

type UseSpring17Declarative = <T>(
	props: Controller.ControllerProps<T>,
	deps: { unknown }?
) -> { [string]: common.ReactBinding }

type UseSpring17Imperative = <T>(
	props: () -> Controller.ControllerProps<T>,
	deps: { unknown }?
) -> ({ [string]: common.ReactBinding }, UseSpringApi<T>)

type UseSpringLegacyRoactDeclarative = <T>(
	hooks: { [string]: any },
	props: Controller.ControllerProps<T>,
	deps: { unknown }?
) -> { [string]: common.ReactBinding }

type UseSpringLegacyRoactImperative = <T>(
	hooks: { [string]: any },
	props: () -> Controller.ControllerProps<T>,
	deps: { unknown }?
) -> ({ [string]: common.ReactBinding }, UseSpringApi<T>)

type UseSpring =
	UseSpring17Declarative
	& UseSpring17Imperative
	& UseSpringLegacyRoactDeclarative
	& UseSpringLegacyRoactImperative

local exports: any

if isRoact17 then
	exports = function<T>(
		props: Controller.ControllerProps<T> | () -> Controller.ControllerProps<T>,
		deps: { unknown }?
	): any
		if type(props) == "function" then
			local styles, api = useSprings(1, props, deps or {})
			return styles[1], api
		else
			local styles = useSprings(1, { props }, deps)
			return styles[1]
		end
	end
else
	exports = function<T>(
		hooks: { [string]: any },
		props: Controller.ControllerProps<T> | () -> Controller.ControllerProps<T>,
		deps: { unknown }?
	): any
		if type(props) == "function" then
			local styles, api = useSprings(hooks, 1, props, deps or {})
			return styles[1], api
		else
			local styles = useSprings(hooks, 1, { props }, deps)
			return styles[1]
		end
	end
end

local exportsTyped: UseSpring = exports
return exportsTyped
