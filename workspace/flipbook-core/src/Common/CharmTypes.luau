local CharmTypes = {}

export type Getter<T> = () -> T
export type Update<T> = ((T) -> T) | T
export type Setter<T> = (Update<T>) -> T

return CharmTypes
