import { Binding } from '@rbxts/roact';
import { CoreHooks } from '@rbxts/roact-hooks';
import { AnimationStyle } from '../../src/types/common';
import { ControllerProps } from '../Controller';

export type UseSpringsApi<T extends AnimationStyle> = {
  start(this: void, fn?: (i: number) => ControllerProps<T>): Promise<void>;
  stop(this: void, keys?: [string]): Promise<void>;
  pause(this: void, keys?: [string]): Promise<void>;
};

declare interface UseSprings {
  <T extends AnimationStyle>(
    hooks: CoreHooks,
    length: number,
    props: Array<ControllerProps<T>>,
    dependencies?: Array<unknown>
  ): Array<{
    [key in keyof T]: Binding<T[key]>;
  }>;
  <T extends AnimationStyle>(
    hooks: CoreHooks,
    length: number,
    props: (i: number) => ControllerProps<T>,
    dependencies?: Array<unknown>
  ): LuaTuple<[Array<{ [key in keyof T]: Binding<T[key]> }>, UseSpringsApi<T>]>;
}

declare const useSprings: UseSprings;
export default useSprings;
