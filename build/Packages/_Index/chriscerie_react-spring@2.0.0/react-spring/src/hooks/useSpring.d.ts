import { Binding } from '@rbxts/roact';
import { CoreHooks } from '@rbxts/roact-hooks';
import { ControllerApi, ControllerProps } from '../Controller';
import { AnimationStyle } from '../types/common';

declare interface UseSpring {
  <T extends AnimationStyle>(hooks: CoreHooks, props: ControllerProps<T>, dependencies?: Array<unknown>): {
    [key in keyof T]: Binding<T[key]>;
  };
  <T extends ControllerProps<AnimationStyle>>(
    hooks: CoreHooks,
    props: () => T,
    dependencies?: Array<unknown>
  ): LuaTuple<[{ [key in keyof T]: Binding<T[key]> }, ControllerApi]>;
}

declare const useSpring: UseSpring;
export default useSpring;
