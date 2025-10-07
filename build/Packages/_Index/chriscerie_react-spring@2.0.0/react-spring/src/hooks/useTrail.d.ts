import { Binding } from '@rbxts/roact';
import { CoreHooks } from '@rbxts/roact-hooks';
import { AnimatableType, AnimationStyle } from '../../src/types/common';
import { ControllerProps } from '../Controller';
import { UseSpringsApi } from './useSprings';

declare interface UseTrail {
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

declare const useTrail: UseTrail;
export default useTrail;
