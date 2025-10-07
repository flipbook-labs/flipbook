import { EasingFunction } from '../constants';

export type AnimatableType = number | UDim | UDim2 | Vector2 | Vector3 | Color3;

type AnimationStyle = {
  [key: string]: AnimatableType;
};

export type AnimationProps<T extends AnimationStyle> = {
  from?: T;
  to?: T;
};

export type SharedAnimationProps = {
  loop?: boolean;
  reset?: boolean;
  default?: boolean;
  config?: AnimationConfigs;
  immediate?: boolean;
  delay?: number;
};

export interface AnimationConfigs {
  tension?: number;
  friction?: number;
  frequency?: number;
  damping?: number;
  mass?: number;
  velocity?: number[];
  restVelocity?: number;
  precision?: number;
  progress?: number;
  duration?: number;
  easing?: EasingFunction;
  clamp?: boolean;
  bounce?: number;
}
