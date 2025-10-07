local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local StateLayerAffordance = require(Foundation.Enums.StateLayerAffordance)
type StateLayerAffordance = StateLayerAffordance.StateLayerAffordance

local StateLayerMode = require(Foundation.Enums.StateLayerMode)
type StateLayerMode = StateLayerMode.StateLayerMode

local CursorType = require(Foundation.Enums.CursorType)
type CursorType = CursorType.CursorType

local ControlState = require(Foundation.Enums.ControlState)
type ControlState = ControlState.ControlState
export type StateChangedCallback = (newState: ControlState) -> ()

local React = require(Packages.React)
export type Bindable<T> = T | React.Binding<T>

type ReactRefGuiObject = React.Ref<GuiObject>

export type NativeCommonProps = {
	AnchorPoint: Bindable<Vector2>?,
	LayoutOrder: Bindable<number>?,
	Position: Bindable<UDim2>?,
	Visible: Bindable<boolean>?,
	ZIndex: Bindable<number>?,
}

export type NativeCallbackProps = {
	onAbsoluteSizeChanged: (instance: GuiObject) -> ()?,
	onAbsolutePositionChanged: (instance: GuiObject) -> ()?,
}

export type CommonProps = {
	testId: string?,
} & NativeCallbackProps & NativeCommonProps

export type FlexItem = {
	FlexMode: Bindable<Enum.UIFlexMode>?,
	GrowRatio: Bindable<number>?,
	ShrinkRatio: Bindable<number>?,
	ItemLineAlignment: Bindable<Enum.ItemLineAlignment>?,
}

export type SizeConstraint = {
	MinSize: Bindable<Vector2?>,
	MaxSize: Bindable<Vector2?>,
}

export type Slice = {
	center: Rect?,
	scale: number?,
}

export type Stroke = {
	Color: Bindable<Color3>?,
	Thickness: Bindable<number>?,
	Transparency: Bindable<number>?,
	LineJoinMode: Bindable<Enum.LineJoinMode>?,
}

export type ColorStyleValue = {
	-- Adding Color3 as an option because of token stupidity
	-- We can clean this up when we update to the new token system	Color3: Bindable<Color3>?,
	Color3: Color3?,
	Transparency: number?,
}

export type ColorStyle = Bindable<ColorStyleValue>

export type ItemId = string | number
export type OnItemActivated = (id: ItemId) -> ()

export type StateLayer = {
	inset: boolean?,
	mode: StateLayerMode?,
	affordance: StateLayerAffordance?,
}

-- SelectionProps are broken out such that any Foundation component that is selectable
-- can have these properties without needing to include the entire Selection type
export type SelectionProps = {
	Selectable: Bindable<boolean>?,
	NextSelectionUp: Bindable<ReactRefGuiObject>?,
	NextSelectionDown: Bindable<ReactRefGuiObject>?,
	NextSelectionLeft: Bindable<ReactRefGuiObject>?,
	NextSelectionRight: Bindable<ReactRefGuiObject>?,
}

-- Unfortunately SelectionProps can't be unioned with Selection
-- without anlyze becoming incredibly unhappy, so we jsut duplicate them.
export type Selection = {
	-- SelectionProps
	Selectable: Bindable<boolean>?,
	NextSelectionUp: Bindable<ReactRefGuiObject>?,
	NextSelectionDown: Bindable<ReactRefGuiObject>?,
	NextSelectionLeft: Bindable<ReactRefGuiObject>?,
	NextSelectionRight: Bindable<ReactRefGuiObject>?,

	-- Additional Selection properties
	SelectionImageObject: Bindable<ReactRefGuiObject>?,
	SelectionOrder: Bindable<number>?,
}

export type SelectionGroup = {
	SelectionBehaviorUp: Bindable<Enum.SelectionBehavior>?,
	SelectionBehaviorDown: Bindable<Enum.SelectionBehavior>?,
	SelectionBehaviorLeft: Bindable<Enum.SelectionBehavior>?,
	SelectionBehaviorRight: Bindable<Enum.SelectionBehavior>?,
}

export type Tags = string | { [string]: boolean }

export type GuiObjectProps = {
	aspectRatio: AspectRatio?,
	cornerRadius: Bindable<UDim>?,
	flexItem: FlexItem?,
	layout: ListLayout?,
	padding: Padding?,
	scale: Bindable<number>?,
	sizeConstraint: SizeConstraint?,
	stroke: Stroke?,

	backgroundStyle: ColorStyle?,
	selection: Selection?,
	cursor: Cursor?,
	selectionGroup: Bindable<boolean>? | SelectionGroup?,

	AutoLocalize: Bindable<boolean>?,
	AutomaticSize: Bindable<Enum.AutomaticSize>?,
	BorderSizePixel: Bindable<number>?,
	BorderColor3: Bindable<Color3>?,
	BorderMode: Bindable<Enum.BorderMode>?,
	ClipsDescendants: Bindable<boolean>?,
	Rotation: Bindable<number>?,
	Size: Bindable<UDim2?>,
	SizeConstraint: Bindable<Enum.SizeConstraint>?,

	stateLayer: StateLayer?, -- Can this be bindable?
	onActivated: ((self: GuiObject, inputObject: InputObject, clickCount: number) -> ())?,
	onSecondaryActivated: ((self: GuiObject, inputObject: InputObject) -> ())?,
	onStateChanged: StateChangedCallback?,
	isDisabled: boolean?, -- This can't be a bindable due to handling state updates

	tag: Tags?,
	children: React.ReactNode?,
}

export type AspectRatioTable = {
	AspectRatio: Bindable<number>,
	AspectType: Bindable<Enum.AspectType>?,
	DominantAxis: Bindable<Enum.DominantAxis>?,
}

export type AspectRatio = Bindable<number> | AspectRatioTable

export type PaddingTable = {
	top: Bindable<UDim>?,
	bottom: Bindable<UDim>?,
	left: Bindable<UDim>?,
	right: Bindable<UDim>?,
}

export type Padding = Bindable<UDim>? | number | Vector2 | UDim2 | PaddingTable

export type ListLayout = {
	FillDirection: Bindable<Enum.FillDirection>,
	ItemLineAlignment: Bindable<Enum.ItemLineAlignment>?,
	HorizontalAlignment: Bindable<Enum.HorizontalAlignment>?,
	HorizontalFlex: Bindable<Enum.UIFlexAlignment>?,
	VerticalAlignment: Bindable<Enum.VerticalAlignment>?,
	VerticalFlex: Bindable<Enum.UIFlexAlignment>?,
	Padding: Bindable<UDim>?,
	SortOrder: Bindable<Enum.SortOrder>?,
	Wraps: Bindable<boolean>?,
}

export type FontFaceTable = {
	Family: string,
	Weight: Enum.FontWeight,
	Style: Enum.FontStyle,
}

export type FontFace = FontFaceTable | Bindable<Font> | Enum.Font

export type FontStyle = {
	Font: FontFace?,
	FontSize: number?,
	LineHeight: number?,
}

export type InternalTextInputRef = {
	getIsFocused: () -> boolean,
	focus: () -> (),
	releaseFocus: () -> (),
	setHover: (isHovering: boolean) -> (),
}

export type TextInputRef = {
	getIsFocused: () -> boolean,
	focus: () -> (),
	releaseFocus: () -> (),
}

export type PopoverAnchor = GuiObject | MeasurableObject

type MeasurableObjectImpl = {
	__index: MeasurableObjectImpl,
	GetPropertyChangedSignal: (self: MeasurableObject, propertyName: string) -> MeasurableObjectSignal<any>,
	SetPosition: (self: MeasurableObject, position: Vector2) -> (),
	SetSize: (self: MeasurableObject, size: Vector2) -> (),
}

type MeasurableObjectSignalConnection = {
	Disconnect: (self: MeasurableObjectSignalConnection) -> (),
}

export type MeasurableObjectSignal<T> = {
	Connect: (self: MeasurableObjectSignal<T>, callback: (value: T) -> ()) -> MeasurableObjectSignalConnection,
}

export type MeasurableObject = typeof(setmetatable(
	{} :: { AbsolutePosition: Vector2, AbsoluteSize: Vector2 },
	{} :: MeasurableObjectImpl
))

export type CursorConfig = {
	radius: UDim?,
	offset: number?,
	borderWidth: number?,
}

export type Cursor = CursorType | CursorConfig

return {}
