return {
	STORY_NAME_PATTERN = "%.story$",
	STORYBOOK_NAME_PATTERN = "%.storybook$",

	-- Enabling dev mode will add flipbook's storybook to the list of available
	-- storybooks to make localy testing easier. It also adds a [DEV] tag to the
	-- plugin
	IS_DEV_MODE = true,

	SPRING_CONFIG = {
		clamp = true,
		mass = 0.6,
		tension = 700,
	},
}
