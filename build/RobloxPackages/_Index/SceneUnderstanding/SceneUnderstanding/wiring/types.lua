export type Wirable = {
	GetConnectedWires: (self: Wirable, pin: string) -> { Wire },
	GetInputPins: (self: Wirable) -> { string },
	GetOutputPins: (self: Wirable) -> { string },
}

export type WirableInstance = Wirable | Instance

return nil
