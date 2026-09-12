export type LaunchData = {
	-- Prepopulates the sidebar search so preview viewers can find stories relevant to the pull request.
	search: string?,
	-- Opens a single story immediately by its sidebar-relative path when the pull request is focused on it.
	story: string?,
}

return {}
