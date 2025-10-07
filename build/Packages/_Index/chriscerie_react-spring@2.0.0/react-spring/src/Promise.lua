local ReplicatedStorage = game:GetService("ReplicatedStorage")

if script.Parent.Parent:FindFirstChild("Promise") then
	return require(script.Parent.Parent.Promise)
end

if ReplicatedStorage:FindFirstChild("rbxts_include") then
	local TS = require(ReplicatedStorage.rbxts_include.RuntimeLib)
	return TS.Promise
end

error("Promise not found. It must be placed in the same folder/hierarchy as react-spring.")
