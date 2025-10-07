-- This file implements a wrapper function for TextService:GetTextSize()
-- Extra padding is added to the returned size because of a rounding issue with GetTextSize
-- TODO: Remove this temporary additional padding when CLIPLAYEREX-1633 is fixed

local TextService = game:GetService("TextService")

local CleanRichTextTags = require(script.Parent.CleanRichTextTags)
local UIBlox = script.Parent.Parent.Parent
local Logger = require(UIBlox.Logger)
local UIBloxConfig = require(UIBlox.UIBloxConfig)

local TEMPORARY_TEXT_SIZE_PADDING = Vector2.new(2, 2)

local function getTextSize(string: string, fontSize: number, font: Enum.Font, frameSize: Vector2, isRichText: boolean?)
	if isRichText and not UIBloxConfig.useEngineRichTextBounds then
		string = CleanRichTextTags(string)
	end

	local params = Instance.new("GetTextBoundsParams")
	params.Font = Font.fromEnum(font)
	params.Size = fontSize
	params.Text = string
	params.Width = frameSize.X
	if UIBloxConfig.useEngineRichTextBounds then
		params.RichText = isRichText or false
	end

	-- pcall because GetTextBoundsAsync can error if network call fails
	local success, value = pcall(function()
		return TextService:GetTextBoundsAsync(params)
	end)
	if success then
		local textSize = Vector2.new(value.X, math.min(value.Y, frameSize.Y))
		return textSize + TEMPORARY_TEXT_SIZE_PADDING
	else
		Logger:warning("GetTextBoundsAsync call failed, falling back to frame size. Error: ", value)
		return frameSize
	end
end

return getTextSize
