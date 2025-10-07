import type { AnySet } from "./Util"

declare namespace SiftSet {
  export function add<T, I>(set: Set<T>, ...values: I[]): Set<T | I>

  export function copy<T extends AnySet>(set: T): T

  export function count<T, S extends Set<T>>(
    set: S,
    predicate?: (item: T) => unknown
  ): number

  export function difference<T>(set: Set<T>, ...sets: Set<T>[]): Set<T>

  export function differenceSymmetric<T>(set: Set<T>, ...sets: Set<T>[]): Set<T>

  export function filter<T, S extends Set<T>>(
    set: S,
    predicate: (item: T, set: Readonly<S>) => unknown
  ): Set<T>

  export function fromArray<T>(array: T[]): Set<T>

  export function has(set: AnySet, item: unknown): boolean

  export function intersection<T>(...sets: Set<T>[]): Set<T>

  export function isSubset<A extends AnySet, B extends AnySet>(
    subset: A,
    superset: B
  ): boolean

  export function isSuperset<A extends AnySet, B extends AnySet>(
    superset: A,
    subset: B
  ): boolean

  export function map<T, R, S extends Set<T>>(
    set: S,
    mapper: (item: T, set: Readonly<S>) => R
  ): Set<R>

  export function merge<T>(...sets: Set<T>[]): Set<T>

  export function subtract<S extends AnySet>(set: S, ...values: unknown[]): S

  export function toArray<T>(set: Set<T>): T[]

  // Aliases
  export { merge as join, merge as union, subtract as delete }
}

export = SiftSet
