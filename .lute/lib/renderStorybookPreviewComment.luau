local function renderStorybookPreviewComment(releasePlaceId: number, branchPlaceId: number): string
	return table.concat({
		"<!-- flipbook-pr-preview -->",
		"## Storybook Preview",
		"",
		`**[▶ Launch Storybook](https://www.roblox.com/games/start?placeId={releasePlaceId})** - <sub><a href="https://www.roblox.com/games/{releasePlaceId}">Experience page ↗</a></sub>`,
		"",
		`**[▶ Launch Storybook (_Branch build_)](https://www.roblox.com/games/start?placeId={branchPlaceId})** - <sub><a href="https://www.roblox.com/games/{branchPlaceId}">Experience page ↗</a></sub>`,
		"",
	}, "\n")
end

return renderStorybookPreviewComment
