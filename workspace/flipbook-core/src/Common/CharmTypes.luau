local CharmTypes = {}

export type Getter<T> = () -> T
export type Update<T> = ((prev: T) -> T) | T
export type Setter<T> = (update: Update<T>) -> T

return CharmTypes
