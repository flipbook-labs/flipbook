import {
  ExcludeNone,
  FromEntries,
  ObjectFromKeyValueArrays,
  ObjectKey,
  ReadonlyDeep,
  TryIndex
} from "./Util"

declare namespace SiftDictionary {
  export function copy<T extends object>(dictionary: T): T

  export function copyDeep<T extends object>(dictionary: T): T

  export function count<T extends object, K extends keyof T>(
    dictionary: T,
    predicate?: (value: T[K], key: K, dictionary: T) => unknown
  ): number

  export function entries<T extends object, K extends keyof T>(
    dictionary: T
  ): [K, T[K]][]

  export function equals(...dictionaries: object[]): boolean

  export function equalsDeep(...dictionaries: object[]): boolean

  export function every<T extends object, K extends keyof T>(
    dictionary: T,
    predicate: (value: T[K], key: K, dictionary: Readonly<T>) => unknown
  ): boolean

  export function filter<T extends object, K extends keyof T>(
    dictionary: T,
    predicate: (value: T[K], key: K, dictionary: Readonly<T>) => unknown
  ): Partial<T>

  export function flatten<T extends object>(
    dictionary: T,
    depth?: number
  ): Record<any, any>

  export function flip<T extends object, K extends keyof T>(
    dictionary: T
  ): Record<any, K>

  export function freeze<T extends object>(dictionary: T): Readonly<T>

  export function freezeDeep<T extends object>(dictionary: T): ReadonlyDeep<T>

  export function fromArrays<K extends ObjectKey, V>(
    keys: K[],
    values: V[]
  ): ObjectFromKeyValueArrays<K[], V[]>

  export function fromEntries<K extends ObjectKey, T extends [K, any][]>(
    entries: T
  ): FromEntries<K, T>

  export function has<T extends object>(dictionary: T, key: unknown): boolean

  export function includes<T extends object>(
    dictionary: T,
    value: unknown
  ): boolean

  export function keys<T extends object, K extends keyof T>(dictionary: T): K[]

  export function map<
    T extends object,
    MV,
    MK extends ObjectKey,
    K extends keyof T
  >(
    dictionary: T,
    mapper: (
      value: T[K],
      key: K,
      dictionary: Readonly<T>
    ) => LuaTuple<[newValue: MV, newKey: MK]> | undefined
  ): {
    [key in MK]: MV
  }

  export function map<T extends object, K extends keyof T, MV>(
    dictionary: T,
    mapper: (value: T[K], key: K, dictionary: Readonly<T>) => MV | undefined
  ): {
    [key in K]: MV
  }

  export function merge<T extends object[]>(
    ...dictionaries: T
  ): ExcludeNone<UnionToIntersection<T[keyof T]>>

  export function mergeDeep<T extends object[]>(
    ...dictionaries: T
  ): ExcludeNone<UnionToIntersection<T[keyof T]>>

  export function removeKey<T extends object, K extends keyof T>(
    dictionary: T,
    key: K
  ): Omit<T, K>

  export function removeKeys<T extends object, K extends keyof T>(
    dictionary: T,
    ...keys: K[]
  ): Omit<T, K>

  export function removeValue<T extends object, V extends T[keyof T]>(
    dictionary: T,
    value: V
  ): ExcludeMembers<T, V>

  export function removeValues<T extends object, V extends T[keyof T][]>(
    dictionary: T,
    ...values: V
  ): ExcludeMembers<T, V>

  export function set<T extends object, K extends keyof T, V extends T[K]>(
    dictionary: T,
    key: K,
    value: V
  ): T & { [key in K]: V }

  export function set<T extends object, K extends ObjectKey, V>(
    dictionary: T,
    key: K,
    value: V
  ): T & { [key in K]: V }

  export function some<T extends object, K extends keyof T>(
    dictionary: T,
    predicate: (value: T[K], key: K, dictionary: Readonly<T>) => unknown
  ): boolean

  export function update<
    T extends object,
    K extends ObjectKey,
    X = TryIndex<T, K>,
    Y = undefined
  >(
    dictionary: T,
    key: K,
    updater?: (value: TryIndex<T, K>, key: K) => X,
    callback?: (key: K) => Y
  ): (TryIndex<T, K> extends undefined
    ? {
        [key in keyof T]: key extends K ? X : T[key]
      }
    : {
        [key in keyof T]: key extends K ? Y : T[key]
      }) & { [key in K]: X }

  export function values<T extends object>(dictionary: T): T[keyof T][]

  export function withKeys<T extends object, K extends keyof T>(
    dictionary: T,
    ...keys: K[]
  ): Pick<T, K>

  // Aliases
  export { merge as join, mergeDeep as joinDeep }
}

export = SiftDictionary
