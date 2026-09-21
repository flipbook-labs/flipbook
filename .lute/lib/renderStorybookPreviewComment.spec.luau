local test = require("@std/test")

local renderStorybookPreviewComment = require("@scripts/lib/renderStorybookPreviewComment")

test.case("renders launch and experience links for both runtimes", function(asserts)
	asserts.eq(
		[[<!-- flipbook-pr-preview -->
## Storybook Preview

**[▶ Launch Storybook](https://www.roblox.com/games/start?placeId=123)** - <sub><a href="https://www.roblox.com/games/123">Experience page ↗</a></sub>

**[▶ Launch Storybook (_Branch build_)](https://www.roblox.com/games/start?placeId=456)** - <sub><a href="https://www.roblox.com/games/456">Experience page ↗</a></sub>
]],
		renderStorybookPreviewComment(123, 456)
	)
end)
