local ReplicatedStorage = game:GetService("ReplicatedStorage")

if script.Parent.Parent:FindFirstChild("React") then
	return require(script.Parent.Parent.React)
end

if ReplicatedStorage:FindFirstChild("rbxts_include") then
	local TS = require(ReplicatedStorage.rbxts_include.RuntimeLib)
	return TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
end

error("React not found. It must be placed in the same folder/hierarchy as react-spring.")
