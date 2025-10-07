local Root = script:FindFirstAncestor("SceneUnderstanding")

local types = require(Root.wiring.types)

type Wirable = types.Wirable

local function getOutputWires(instance: Wirable): { Wire }
	local wires: { Wire } = {}
	local pins = instance:GetOutputPins()

	for _, pin in pins do
		for _, wire in instance:GetConnectedWires(pin) do
			table.insert(wires, wire)
		end
	end

	return wires
end

return getOutputWires
