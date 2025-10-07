import { Binding } from '@rbxts/roact';
import { AnimationProps, AnimationStyle, SharedAnimationProps } from './types/common';

export type ControllerProps<T extends AnimationStyle> = (AnimationProps<T> | T) & SharedAnimationProps;

export interface ControllerApi {
  start(startProps?: ControllerProps<AnimationStyle>): Promise<void>;
  stop(keys?: [string]): Promise<void>;
  pause(keys?: [string]): Promise<void>;
}

declare interface Constructor {
  new <T extends AnimationStyle>(props: ControllerProps<T>): LuaTuple<
    [{ [key in keyof T]: Binding<T[key]> }, ControllerApi]
  >;
}

declare const Controller: Constructor;
export default Controller;
