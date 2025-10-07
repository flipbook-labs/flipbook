local Players = game:GetService("Players")

local character =
	Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
local humanoid = character:FindFirstChildOfClass("Humanoid")

assert(humanoid, "Humanoid must exist in character model")

local bodyTypeScale = humanoid:FindFirstChild("BodyTypeScale") :: NumberValue
local bodyProportionScale = humanoid:FindFirstChild("BodyProportionScale") :: NumberValue

bodyTypeScale.Value = 0
bodyProportionScale.Value = 0

local attachmentToPart = {}

for _, part in pairs(character:GetDescendants()) do
	if part:IsA("BasePart") then
		for _, attachment in part:GetChildren() do
			if not attachment:IsA("Attachment") then
				continue
			end
			attachmentToPart[attachment.Name] = humanoid:GetBodyPartR15(part)
		end
	end
end

return function(handle: BasePart, attachment: Attachment)
	return humanoid:GetAccessoryHandleScale(handle, attachmentToPart[attachment.Name])
end
