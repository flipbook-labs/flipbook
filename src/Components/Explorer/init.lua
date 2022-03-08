local Roact = require(script.Parent.Parent.Packages.Roact)
local ExplorerNode = require(script.ExplorerNode)
local types = require(script.types)

local e = Roact.createElement

export type Node = types.Node
export type Props = {
	activeNode: types.Node?,
	nodes: { types.Node },
	onNodeActivated: (types.Node) -> (),
}

local function Explorer(props: Props) end
