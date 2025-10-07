--!nonstrict
local function createLegacyAccessoryMeshPartAssetFormatSchema(attachmentName)
	assert(attachmentName, "attachmentName cannot be nil")
	return {
		ClassName = "Accessory",
		_children = {
			{
				Name = "ThumbnailConfiguration",
				ClassName = "Configuration",
				_optional = true,
				_children = {
					{
						Name = "ThumbnailCameraTarget",
						ClassName = "ObjectValue",
					},
					{
						Name = "ThumbnailCameraValue",
						ClassName = "CFrameValue",
					},
				},
			},
			{
				Name = "Handle",
				ClassName = "MeshPart",
				_children = {
					{
						Name = attachmentName,
						ClassName = "Attachment",
					},
					{
						ClassName = "SurfaceAppearance",
						Name = "SurfaceAppearance",
						_optional = true,
					},
					{
						ClassName = "StringValue",
						Name = "AvatarPartScaleType",
						_optional = true,
					},
					{
						ClassName = "TouchTransmitter",
						_optional = true,
					},
				},
			},
		},
	}
end

return createLegacyAccessoryMeshPartAssetFormatSchema
