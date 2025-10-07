local types = require(script.types)
local utility = require(script.utility)
local theme = require(script.theme)

local Highlighter = {
	defaultLexer = require(script.lexer) :: types.Lexer,

	_textObjectData = {} :: { [types.TextObject]: types.ObjectData },
	_cleanups = {} :: { [types.TextObject]: () -> () },
}

--[[
	Gathers the info that is needed in order to set up a line label.
]]
function Highlighter._getLabelingInfo(textObject: types.TextObject)
	local data = Highlighter._textObjectData[textObject]
	if not data then
		return
	end

	local src = utility.convertTabsToSpaces(utility.removeControlChars(textObject.Text))
	local numLines = #string.split(src, "\n")
	if numLines == 0 then
		return
	end

	local textBounds = utility.getTextBounds(textObject)
	local textHeight = textBounds.Y / numLines

	return {
		data = data,
		numLines = numLines,
		textBounds = textBounds,
		textHeight = textHeight,
		innerAbsoluteSize = utility.getInnerAbsoluteSize(textObject),
		textColor = theme.getColor("iden"),
		textFont = textObject.FontFace,
		textSize = textObject.TextSize,
		labelSize = UDim2.new(1, 0, 0, math.ceil(textHeight)),
	}
end

--[[
	Aligns and matches the line labels to the textObject.
]]
function Highlighter._alignLabels(textObject: types.TextObject)
	local labelingInfo = Highlighter._getLabelingInfo(textObject)
	if not labelingInfo then
		return
	end

	for lineNumber, lineLabel in labelingInfo.data.Labels do
		-- Align line label
		lineLabel.TextColor3 = labelingInfo.textColor
		lineLabel.FontFace = labelingInfo.textFont
		lineLabel.TextSize = labelingInfo.textSize
		lineLabel.Size = labelingInfo.labelSize
		lineLabel.Position =
			UDim2.fromScale(0, labelingInfo.textHeight * (lineNumber - 1) / labelingInfo.innerAbsoluteSize.Y)
	end
end

--[[
	Creates and populates the line labels with the appropriate rich text.
]]
function Highlighter._populateLabels(props: types.HighlightProps)
	-- Gather props
	local textObject = props.textObject
	local src = utility.convertTabsToSpaces(utility.removeControlChars(props.src or textObject.Text))
	local lexer = props.lexer or Highlighter.defaultLexer
	local customLang = props.customLang
	local forceUpdate = props.forceUpdate

	-- Avoid updating when unnecessary
	local data = Highlighter._textObjectData[textObject]
	if (data == nil) or (data.Text == src) then
		if forceUpdate ~= true then
			return
		end
	end

	-- Ensure textObject matches sanitized src
	textObject.Text = src

	local lineLabels = data.Labels
	local previousLines = data.Lines

	local lines = string.split(src, "\n")

	data.Lines = lines
	data.Text = src
	data.Lexer = lexer
	data.CustomLang = customLang

	-- Shortcut empty textObjects
	if src == "" then
		for l = 1, #lineLabels do
			if lineLabels[l].Text == "" then
				continue
			end
			lineLabels[l].Text = ""
		end
		return
	end

	local idenColor = theme.getColor("iden")
	local labelingInfo = Highlighter._getLabelingInfo(textObject)

	local richTextBuffer, bufferIndex, lineNumber = table.create(5), 0, 1
	for token: types.TokenName, content: string in lexer.scan(src) do
		local Color = if customLang and customLang[content]
			then theme.getColor("custom")
			else theme.getColor(token) or idenColor

		local tokenLines = string.split(utility.sanitizeRichText(content), "\n")

		for l, tokenLine in tokenLines do
			-- Find line label
			local lineLabel = lineLabels[lineNumber]
			if not lineLabel then
				local newLabel = Instance.new("TextLabel")
				newLabel.Name = "Line_" .. lineNumber
				newLabel.AutoLocalize = false
				newLabel.RichText = true
				newLabel.BackgroundTransparency = 1
				newLabel.Text = ""
				newLabel.TextXAlignment = Enum.TextXAlignment.Left
				newLabel.TextYAlignment = Enum.TextYAlignment.Top
				newLabel.TextColor3 = labelingInfo.textColor
				newLabel.FontFace = labelingInfo.textFont
				newLabel.TextSize = labelingInfo.textSize
				newLabel.Size = labelingInfo.labelSize
				newLabel.Position =
					UDim2.fromScale(0, labelingInfo.textHeight * (lineNumber - 1) / labelingInfo.innerAbsoluteSize.Y)

				newLabel.Parent = textObject.SyntaxHighlights
				lineLabels[lineNumber] = newLabel
				lineLabel = newLabel
			end

			-- If multiline token, then set line & move to next
			if l > 1 then
				if forceUpdate or lines[lineNumber] ~= previousLines[lineNumber] then
					-- Set line
					lineLabels[lineNumber].Text = table.concat(richTextBuffer)
				end
				-- Move to next line
				lineNumber += 1
				bufferIndex = 0
				table.clear(richTextBuffer)
			end

			-- If changed, add token to line
			if forceUpdate or lines[lineNumber] ~= previousLines[lineNumber] then
				bufferIndex += 1
				-- Only add RichText tags when the color is non-default and the characters are non-whitespace
				if Color ~= idenColor and string.find(tokenLine, "[%S%C]") then
					richTextBuffer[bufferIndex] = theme.getColoredRichText(Color, tokenLine)
				else
					richTextBuffer[bufferIndex] = tokenLine
				end
			end
		end
	end

	-- Set final line
	if richTextBuffer[1] and lineLabels[lineNumber] then
		lineLabels[lineNumber].Text = table.concat(richTextBuffer)
	end

	-- Clear unused line labels
	for l = lineNumber + 1, #lineLabels do
		if lineLabels[l].Text == "" then
			continue
		end
		lineLabels[l].Text = ""
	end
end

--[[
	Builds rich text lines from the given source code.
	Useful for cases where you want to render the labels yourself for something.
]]
function Highlighter.buildRichTextLines(props: types.BuildRichTextLinesProps): { string }
	-- Gather props
	local src = utility.convertTabsToSpaces(utility.removeControlChars(props.src))
	local lexer = props.lexer or Highlighter.defaultLexer
	local customLang = props.customLang
	local idenColor = theme.getColor("iden")

	local richTextLines = table.create(select(2, string.gsub(src, "\n", "\n")) + 1)
	local richTextBuffer, bufferIndex = table.create(5), 0
	local lineNumber = 1

	for token: types.TokenName, content: string in lexer.scan(src) do
		local Color = if customLang and customLang[content]
			then theme.getColor("custom")
			else theme.getColor(token) or idenColor

		local tokenLines = string.split(utility.sanitizeRichText(content), "\n")

		for l, tokenLine in tokenLines do
			-- If multiline token, then set line & move to next
			if l > 1 then
				-- Set line
				richTextLines[lineNumber] = table.concat(richTextBuffer)
				-- Move to next line
				lineNumber += 1
				bufferIndex = 0
				table.clear(richTextBuffer)
			end

			bufferIndex += 1
			-- Only add RichText tags when the characters are non-whitespace
			if string.find(tokenLine, "[%S%C]") then
				richTextBuffer[bufferIndex] = theme.getColoredRichText(Color, tokenLine)
			else
				richTextBuffer[bufferIndex] = tokenLine
			end
		end
	end

	-- Set final line
	richTextLines[lineNumber] = table.concat(richTextBuffer)

	return richTextLines
end

--[[
	Highlights the given textObject with the given props and returns a cleanup function.
	Highlighting will automatically update when needed, so the cleanup function will disconnect
	those connections and remove all labels.
]]
function Highlighter.highlight(props: types.HighlightProps): () -> ()
	-- Gather props
	local textObject = props.textObject
	local src = utility.convertTabsToSpaces(utility.removeControlChars(props.src or textObject.Text))
	local lexer = props.lexer or Highlighter.defaultLexer
	local customLang = props.customLang

	-- Avoid updating when unnecessary
	if Highlighter._cleanups[textObject] then
		-- Already been initialized, so just update
		Highlighter._populateLabels(props)
		Highlighter._alignLabels(textObject)
		return Highlighter._cleanups[textObject]
	end

	-- Ensure valid object properties
	textObject.RichText = false
	textObject.Text = src
	textObject.TextXAlignment = Enum.TextXAlignment.Left
	textObject.TextYAlignment = Enum.TextYAlignment.Top
	textObject.BackgroundColor3 = theme.getColor("background")
	textObject.TextColor3 = theme.getColor("iden")
	textObject.TextTransparency = 0.5

	-- Build the highlight labels
	local lineFolder = textObject:FindFirstChild("SyntaxHighlights")
	if lineFolder == nil then
		local newLineFolder = Instance.new("Folder")
		newLineFolder.Name = "SyntaxHighlights"
		newLineFolder.Parent = textObject

		lineFolder = newLineFolder
	end

	local data = {
		Text = "",
		Labels = {},
		Lines = {},
		Lexer = lexer,
		CustomLang = customLang,
	}
	Highlighter._textObjectData[textObject] = data

	-- Add a cleanup handler for this textObject
	local connections: { [string]: RBXScriptConnection } = {}
	local function cleanup()
		lineFolder:Destroy()

		Highlighter._textObjectData[textObject] = nil
		Highlighter._cleanups[textObject] = nil

		for _key, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
	end
	Highlighter._cleanups[textObject] = cleanup

	connections["AncestryChanged"] = textObject.AncestryChanged:Connect(function()
		if textObject.Parent then
			return
		end

		cleanup()
	end)
	connections["TextChanged"] = textObject:GetPropertyChangedSignal("Text"):Connect(function()
		Highlighter._populateLabels(props)
	end)
	connections["TextBoundsChanged"] = textObject:GetPropertyChangedSignal("TextBounds"):Connect(function()
		Highlighter._alignLabels(textObject)
	end)
	connections["AbsoluteSizeChanged"] = textObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		Highlighter._alignLabels(textObject)
	end)
	connections["FontFaceChanged"] = textObject:GetPropertyChangedSignal("FontFace"):Connect(function()
		Highlighter._alignLabels(textObject)
	end)

	-- Populate the labels
	Highlighter._populateLabels(props)
	Highlighter._alignLabels(textObject)

	return cleanup
end

--[[
	Refreshes all highlighted textObjects. Used when the theme changes.
]]
function Highlighter.refresh(): ()
	-- Rehighlight existing labels using latest colors
	for textObject, data in Highlighter._textObjectData do
		for _, lineLabel in data.Labels do
			lineLabel.TextColor3 = theme.getColor("iden")
		end

		Highlighter.highlight({
			textObject = textObject,
			forceUpdate = true,
			src = data.Text,
			lexer = data.Lexer,
			customLang = data.CustomLang,
		})
	end
end

--[[
	Sets the token colors to the given colors and refreshes all highlighted textObjects.
]]
function Highlighter.setTokenColors(colors: types.TokenColors): ()
	theme.setColors(colors)

	Highlighter.refresh()
end

--[[
	Gets a token color by name.
	Mainly useful for setting "background" token color on other UI objects behind your text.
]]
function Highlighter.getTokenColor(tokenName: types.TokenName): Color3
	return theme.getColor(tokenName)
end

--[[
	Matches the token colors to the Studio theme settings and refreshes all highlighted textObjects.
	Does nothing when not run in a Studio plugin.
]]
function Highlighter.matchStudioSettings(): ()
	local applied = theme.matchStudioSettings(Highlighter.refresh)
	if applied then
		Highlighter.refresh()
	end
end

return Highlighter
