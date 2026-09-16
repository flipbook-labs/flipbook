local JestGlobals = require("@pkg/JestGlobals")

local doesTreeNodeMatchSearch = require("./doesTreeNodeMatchSearch")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("matches any pipe-separated alternative", function()
	expect(doesTreeNodeMatchSearch("RobloxProfile", "SuccessDialog|RobloxProfile")).toBe(true)
	expect(doesTreeNodeMatchSearch("SuccessDialog", "SuccessDialog|RobloxProfile")).toBe(true)
	expect(doesTreeNodeMatchSearch("FeedbackDialog", "SuccessDialog|RobloxProfile")).toBe(false)
end)

test("matches alternatives case-insensitively and ignores surrounding spaces", function()
	expect(doesTreeNodeMatchSearch("RobloxProfile", "successdialog | robloxprofile")).toBe(true)
end)

test("treats alternatives as literal text", function()
	expect(doesTreeNodeMatchSearch("Story[One]", "[")).toBe(true)
	expect(doesTreeNodeMatchSearch("StoryOne", "[")).toBe(false)
end)
