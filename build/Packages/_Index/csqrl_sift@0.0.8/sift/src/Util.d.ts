export type SiftNone = { readonly __none__: unique symbol }
export type ExcludeNone<T> = Exclude<T, SiftNone>
export type ObjectKey = string | number | symbol
export type AnySet = Set<unknown>

export type FromEntries<K extends ObjectKey, T extends [K, any][]> = {
  [P in T[number][0]]: Extract<T[number], [P, any]>[1]
}

export type ReadonlyDeep<T> = T extends (infer U)[]
  ? ReadonlyDeepArray<U>
  : T extends Callback
  ? T
  : T extends object
  ? ReadonlyDeepObject<T>
  : T

export type ObjectFromKeyValueArrays<
  Keys extends Array<ObjectKey>,
  Values extends Array<any>
> = ObjectFromKeyValuePairs<KeyValuePairsFromLists<Keys, Values>>

export type ReplaceType<T, F, R> = F extends T ? Exclude<T, F> | R : T

export type TryIndex<T extends object, K> = K extends keyof T ? T[K] : undefined

interface ReadonlyDeepArray<T> extends ReadonlyArray<ReadonlyDeep<T>> {}

type ReadonlyDeepObject<T> = {
  readonly [P in keyof T]: ReadonlyDeep<T[P]>
}

type KeyValuePairsFromLists<
  Keys extends Array<ObjectKey>,
  Values extends Array<any>
> = {
  [index in keyof Keys]: index extends keyof Values
    ? [Keys[index], Values[index]]
    : never
}

type ObjectFromKeyValuePairs<
  KV extends [ObjectKey, any][],
  T = {
    [index in keyof KV]: KV[index] extends [ObjectKey, any]
      ? Record<KV[index][0], KV[index][1]>
      : never
  }
> = UnionToIntersection<T[keyof T]>
