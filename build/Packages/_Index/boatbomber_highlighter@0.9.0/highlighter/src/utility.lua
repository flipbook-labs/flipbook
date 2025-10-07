local types = require(script.Parent.types)

local Utility = {}

function Utility.sanitizeRichText(s: string): string
	return string.gsub(
		string.gsub(string.gsub(string.gsub(string.gsub(s, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"), '"', "&quot;"),
		"'",
		"&apos;"
	)
end

function Utility.convertTabsToSpaces(s: string): string
	return string.gsub(s, "\t", "    ")
end

function Utility.removeControlChars(s: string): string
	return string.gsub(s, "[\0\1\2\3\4\5\6\7\8\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31]+", "")
end

function Utility.getInnerAbsoluteSize(textObject: types.TextObject): Vector2
	local fullSize = textObject.AbsoluteSize

	local padding: UIPadding? = textObject:FindFirstChildWhichIsA("UIPadding")
	if padding then
		local offsetX = padding.PaddingLeft.Offset + padding.PaddingRight.Offset
		local scaleX = (fullSize.X * padding.PaddingLeft.Scale) + (fullSize.X * padding.PaddingRight.Scale)
		local offsetY = padding.PaddingTop.Offset + padding.PaddingBottom.Offset
		local scaleY = (fullSize.Y * padding.PaddingTop.Scale) + (fullSize.Y * padding.PaddingBottom.Scale)
		return Vector2.new(fullSize.X - (scaleX + offsetX), fullSize.Y - (scaleY + offsetY))
	else
		return fullSize
	end
end

function Utility.getTextBounds(textObject: types.TextObject): Vector2
	if textObject.ContentText == "" then
		return Vector2.zero
	end

	local textBounds = textObject.TextBounds

	-- Wait for TextBounds to be non-NaN and non-zero because Roblox
	while (textBounds.Y ~= textBounds.Y) or (textBounds.Y < 1) do
		task.wait()
		textBounds = textObject.TextBounds
	end
	return textBounds
end

return Utility
