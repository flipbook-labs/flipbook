local ButtonRoot = script.Parent
local App = ButtonRoot.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent
local Core = UIBlox.Core

local Foundation = require(Packages.Foundation)
local ButtonVariant = Foundation.Enums.ButtonVariant
local InputSize = Foundation.Enums.InputSize

local ButtonType = require(ButtonRoot.Enum.ButtonType)
local StandardButtonSize = require(Core.Button.Enum.StandardButtonSize)

local ImagesInverse = require(App.ImageSet.ImagesInverse)

local buttonMapping = {
	[ButtonType.Alert] = ButtonVariant.Alert,
	[ButtonType.PrimaryContextual] = ButtonVariant.Emphasis,
	[ButtonType.PrimarySystem] = ButtonVariant.SubEmphasis,
	[ButtonType.Secondary] = ButtonVariant.Subtle,
}

local sizeMapping = {
	[StandardButtonSize.Regular] = InputSize.Large,
	[StandardButtonSize.Small] = InputSize.Small,
	[StandardButtonSize.XSmall] = InputSize.XSmall,
}

local fitContentDefaultMapping = {
	[StandardButtonSize.Regular] = false,
	[StandardButtonSize.Small] = false,
	[StandardButtonSize.XSmall] = true,
}

local function findIcon(searchData)
	if not searchData then
		return nil
	end
	local icon = ImagesInverse[searchData]
	if icon == nil then
		warn("Icon not found")
	end
	return icon
end

local function getSizeMapping(standardSize, size: UDim2?, tokens: typeof(Foundation.Hooks.useTokens()))
	if standardSize then
		return sizeMapping[standardSize]
	elseif size then
		if size.Y.Offset >= tokens.Size.Size_1200 then
			return InputSize.Large
		elseif size.Y.Scale > 0 then
			return InputSize.Medium
		elseif size.Y.Offset >= tokens.Size.Size_1000 then
			return InputSize.Medium
		elseif size.Y.Offset >= tokens.Size.Size_800 then
			return InputSize.Small
		else
			return InputSize.XSmall
		end
	end
	return nil
end

local function getWidth(standardSize: string?, size: UDim2?, maxWidth: number?, fitContent: boolean?): UDim?
	maxWidth = maxWidth or 640

	if standardSize then
		local fitContentDefault = fitContentDefaultMapping[standardSize]
		if fitContent == nil then
			fitContent = fitContentDefault
		end

		if fitContent then
			return nil
		end

		size = UDim2.fromScale(1, 0)

		if maxWidth then
			-- Size should be the minimum of the props size and the max width
			if size and size.X.Offset > 0 then
				return UDim.new(0, math.min(size.X.Offset, maxWidth))
			end
		end
		return UDim.new(0, maxWidth)
	elseif size then
		return size.X
	elseif fitContent then
		return nil
	else
		return UDim.new(1, 0)
	end
end

local function getTestId(tag: string?): string?
	if not tag or #tag == 0 then
		return nil
	end

	return tag:match("data%-testid=([^%s]+)")
end

return {
	buttonMapping = buttonMapping,
	sizeMapping = sizeMapping,
	findIcon = findIcon,
	getSizeMapping = getSizeMapping,
	getWidth = getWidth,
	getTestId = getTestId,
}
