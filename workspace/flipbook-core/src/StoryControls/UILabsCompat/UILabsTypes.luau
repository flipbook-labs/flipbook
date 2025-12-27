type ControlType = "String" | "Number" | "Boolean" | "Object" | "RGBA" | "Choose" | "EnumList" | "Slider"

type BaseControl<T> = {
	ControlValue: T,
	EntryType: "Control",
}

export type NumberControl = BaseControl<number> & {
	Type: "Number",
	Min: number?,
	Max: number?,
	Step: number?,
	Dragger: boolean,
	Sensibility: number,
}

type StringFilterFn = (input: string, oldInput: string) -> string

export type StringControl = BaseControl<string> & {
	Type: "String",
	Filters: { StringFilterFn }?,
}

export type BooleanControl = BaseControl<boolean> & {
	Type: "Boolean",
}

export type RGBAControl = BaseControl<{ Color: Color3, Transparency: number }> & {
	Type: "RGBA",
}

export type ObjectControl = BaseControl<Instance> & {
	Type: "Object",
}

export type SliderControl = BaseControl<number> & {
	Type: "Slider",
	Max: number,
	Min: number,
	Step: number?,
}

export type ChooseControl<T> = BaseControl<T> & {
	Type: "Choose",
	List: { T },
	DefIndex: number,
}

export type EnumListControl<T> = BaseControl<T> & {
	Type: "EnumList",
	EntryType: "Control",
	List: { [string]: any },
	DefIndex: string,
}

export type Control =
	StringControl
	| NumberControl
	| BooleanControl
	| ObjectControl
	| RGBAControl
	| SliderControl
	| ChooseControl<unknown>
	| EnumListControl<unknown>

export type ControlGroup = {
	EntryType: "ControlGroup",
	Controls: { [string]: Control },
}

export type ControlsSchema = {
	[string]: Control | ControlGroup,
}

return nil
