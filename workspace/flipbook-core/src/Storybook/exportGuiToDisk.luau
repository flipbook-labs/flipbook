local AssetService = game:GetService("AssetService")
local CaptureService = game:GetService("CaptureService")
local CoreGui = game:GetService("CoreGui")
local Selection = game:GetService("Selection")

local PluginStore = require("@root/Plugin/PluginStore")

Selection:Set({})

local function exportGuiToDisk(gui: GuiObject)
	if gui.AbsolutePosition.X % 1 ~= 0 or gui.AbsolutePosition.Y % 1 ~= 0 then
		warn(
			"Gui to export occupies a half-pixel position which will result in blurry image. Make sure AbsolutePosition is represented by whole numbers and try again"
		)
	end

	local export = gui:Clone()

	local screen = Instance.new("ScreenGui")

	export.Parent = screen

	screen.Parent = CoreGui

	-- TODO: Clone `export` to a ScreenGui

	CaptureService:CaptureScreenshot(function(assetId)
		local screenshot = AssetService:CreateEditableImageAsync(assetId)

		local cropped = AssetService:CreateEditableImage({
			Size = export.AbsoluteSize,
		})

		cropped:DrawImageTransformed(Vector2.zero, Vector2.one, 0, screenshot, {
			CombineType = Enum.ImageCombineType.Overwrite,
			PivotPoint = export.AbsolutePosition,
		})

		-- preview.Size = UDim2.fromOffset(export.AbsoluteSize.X, export.AbsoluteSize.Y)
		-- preview.ImageContent = Content.fromObject(cropped)

		Selection:Set({ cropped })

		local plugin = PluginStore.get(false).getPlugin(false)
		if plugin then
			plugin:PromptSaveSelection(`{export.Name}.png`)
		end
	end)
end

return exportGuiToDisk
