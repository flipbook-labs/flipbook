local function getAttachment(parent: Instance, names: { string }): Attachment?
	for _, name in pairs(names) do
		local result = parent:FindFirstChild(name)
		if result then
			if result:IsA("Attachment") then
				return result
			else
				return result :: Attachment
			end
		end
	end
	return nil
end

return getAttachment
