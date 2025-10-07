local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getRobloxTsRuntime()
	local rbxtsInclude = ReplicatedStorage:FindFirstChild("rbxts_include")
	if rbxtsInclude then
		return rbxtsInclude:FindFirstChild("RuntimeLib")
	end
	return nil
end

return getRobloxTsRuntime
