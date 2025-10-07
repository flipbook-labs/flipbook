--!strict
local constants = require(script.Parent.Parent.constants)

export type AnimatableType = number | UDim | UDim2 | Vector2 | Vector3 | Color3

export type AnimationStyle = {
	[string]: AnimatableType,
}

export type AnimationProps = {
	loop: boolean?,
	reset: boolean?,
	default: boolean?,
	config: AnimationConfigs?,
	immediate: boolean?,
	delay: number?,
}

export type AnimationConfigs = {
	tension: number?,
	friction: number?,
	frequency: number?,
	damping: number?,
	mass: number?,
	velocity: { number }?,
	restVelocity: number?,
	precision: number?,
	progress: number?,
	duration: number?,
	easing: constants.EasingFunction?,
	clamp: boolean?,
	bounce: number?,
}

export type ReactBinding = {
	getValue: (self: ReactBinding) -> any,
	map: <U>(self: ReactBinding, (any) -> any) -> any,
}

return {}
