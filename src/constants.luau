return {
	STORY_NAME_PATTERN = "%.story$",
	STORYBOOK_NAME_PATTERN = "%.storybook$",

	SIDEBAR_INITIAL_WIDTH = 260, -- px
	SIDEBAR_MIN_WIDTH = 140, -- px
	SIDEBAR_MAX_WIDTH = 500, -- px

	CONTROLS_INITIAL_HEIGHT = 200, -- px
	CONTROLS_MIN_HEIGHT = 100, -- px
	CONTROLS_MAX_HEIGHT = 400, -- px

	-- Enabling dev mode will add Flipbook's storybook to the list of available
	-- storybooks to make localy testing easier. It also adds a [DEV] tag to the
	-- plugin
	IS_DEV_MODE = false,

	SPRING_CONFIG = {
		clamp = true,
		mass = 0.6,
		tension = 700,
	},
}
