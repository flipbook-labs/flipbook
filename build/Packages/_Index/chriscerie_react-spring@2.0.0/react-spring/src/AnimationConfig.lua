local constants = require(script.Parent.constants)
local util = require(script.Parent.util)

local AnimationConfig = {}

local defaults = table.freeze(util.merge(constants.config.default, {
	mass = 1,
	damping = 1,
	clamp = false,
	velocity = 0,
	easing = constants.easings.linear,
}))

export type SpringConfigs = {
	--[[
        Higher mass means more friction is required to slow down.
        Defaults to 1, which works fine most of the time.
    ]]
	mass: number?,

	--[[
        With higher tension, the spring will resist bouncing and try harder to stop at its end value.
        When tension is zero, no animation occurs.
    ]]
	tension: number?,

	--[[
        The damping ratio coefficient.
        Higher friction means the spring will slow down faster.
    ]]
	friction: number?,

	--[[
        Avoid overshooting by ending abruptly at the goal value.
    ]]
	clamp: boolean?,

	--[[
        The smallest distance from a value before that distance is essentially zero.

        This helps in deciding when a spring is "at rest". The spring must be within
        this distance from its final value, and its velocity must be lower than this
        value too (unless `restVelocity` is defined).
    ]]
	precision: number?,

	--[[
        For `duration` animations only. Note: The `duration` is not affected
        by this property.
        
        Defaults to `0`, which means "start from the beginning".
        
        Setting to `1+` makes an immediate animation.
        
        Setting to `0.5` means "start from the middle of the easing function".
    
        Any number `>= 0` and `<= 1` makes sense here.
    ]]
	progress: number?,

	--[[
        The initial velocity of one or more values.
    ]]
	velocity: number | { number }?,

	--[[
        The animation curve. Only used when `duration` is defined.
    ]]
	easing: (t: number) -> number?,

	--[[
        The damping ratio, which dictates how the spring slows down.
        
        Set to `0` to never slow down. Set to `1` to slow down without bouncing.
        Between `0` and `1` is for you to explore.
        
        Only works when `frequency` is defined.
    ]]
	damping: number?,

	--[[
        Animation length in number of seconds.
    ]]
	duration: number?,

	--[[
        The natural frequency (in seconds), which dictates the number of bounces
        per second when no damping exists.
        
        When defined, `tension` is derived from this, and `friction` is derived
        from `tension` and `damping`.
    ]]
	frequency: number?,

	--[[
        When above zero, the spring will bounce instead of overshooting when
        exceeding its goal value. Its velocity is multiplied by `-1 + bounce`
        whenever its current value equals or exceeds its goal. For example,
        setting `bounce` to `0.5` chops the velocity in half on each bounce,
        in addition to any friction.
    ]]
	bounce: number?,

	--[[
        The smallest velocity before the animation is considered "not moving".
        When undefined, `precision` is used instead.
    ]]
	restVelocity: number?,
}

function AnimationConfig:mergeConfig(config: any, newConfig: any?): SpringConfigs
	if newConfig then
		config = util.merge(config, newConfig)
	else
		config = table.clone(config)
	end

	for k, v in pairs(defaults) do
		if config[k] == nil then
			config[k] = v
		end
	end

	if config.frequency ~= nil then
		if config.frequency < 0.01 then
			config.frequency = 0.01
		end
		if config.damping < 0 then
			config.damping = 0
		end
		config.tension = ((2 * math.pi / config.frequency) ^ 2) * config.mass
		config.friction = (4 * math.pi * config.damping * config.mass) / config.frequency
	end

	return config
end

return AnimationConfig
