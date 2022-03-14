return {
	STORY_NAME_PATTERN = "%.story$",
	STORYBOOK_NAME_PATTERN = "%.storybook$",

	-- Determines whether or not flipbook's storybook will appear in the
	-- storybook list. Regular users will not need to see this, but it helps
	-- when debugging.
	DEBUG_SHOW_INTERNAL_STORYBOOK = false,

	SPRING_CONFIG = {
		clamp = true,
		mass = 0.6,
		tension = 700,
	},
}
