local Boolean = require(script.Parent:WaitForChild('boolean'))
local Collections = require(script.Parent:WaitForChild('collections'))
local Console = require(script.Parent:WaitForChild('console'))
local Math = require(script.Parent:WaitForChild('math'))
local Number = require(script.Parent:WaitForChild('number'))
local String = require(script.Parent:WaitForChild('string'))
local Symbol = require(script.Parent:WaitForChild('symbol-luau'))
local Timers = require(script.Parent:WaitForChild('timers'))
local types = require(script.Parent:WaitForChild('es7-types'))

local AssertionError = require(script:WaitForChild('AssertionError'))
local Error = require(script:WaitForChild('Error'))
local PromiseModule = require(script:WaitForChild('Promise'))
local extends = require(script:WaitForChild('extends'))
local instanceof = require(script.Parent:WaitForChild('instance-of'))

export type Array<T> = types.Array<T>
export type AssertionError = AssertionError.AssertionError
export type Error = Error.Error
export type Map<T, V> = types.Map<T, V>
export type Object = types.Object

export type PromiseLike<T> = PromiseModule.PromiseLike<T>
export type Promise<T> = PromiseModule.Promise<T>

export type Set<T> = types.Set<T>
export type Symbol = Symbol.Symbol
export type Timeout = Timers.Timeout
export type Interval = Timers.Interval
export type WeakMap<T, V> = Collections.WeakMap<T, V>

return {
	Array = Collections.Array,
	AssertionError = AssertionError,
	Boolean = Boolean,
	console = Console,
	Error = Error,
	extends = extends,
	instanceof = instanceof,
	Math = Math,
	Number = Number,
	Object = Collections.Object,
	Map = Collections.Map,
	coerceToMap = Collections.coerceToMap,
	coerceToTable = Collections.coerceToTable,
	Set = Collections.Set,
	WeakMap = Collections.WeakMap,
	String = String,
	Symbol = Symbol,
	setTimeout = Timers.setTimeout,
	clearTimeout = Timers.clearTimeout,
	setInterval = Timers.setInterval,
	clearInterval = Timers.clearInterval,
	util = {
		inspect = Collections.inspect,
	},
}
