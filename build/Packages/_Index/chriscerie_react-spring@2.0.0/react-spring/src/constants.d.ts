export type EasingFunction = (t: number) => number;

export interface Config {
  default: { tension: 170; friction: 26 };
  gentle: { tension: 120; friction: 14 };
  wobbly: { tension: 180; friction: 12 };
  stiff: { tension: 210; friction: 20 };
  slow: { tension: 280; friction: 60 };
  molasses: { tension: 280; friction: 120 };
}

export interface EasingDictionary {
  linear: EasingFunction;
  easeInQuad: EasingFunction;
  easeOutQuad: EasingFunction;
  easeInOutQuad: EasingFunction;
  easeInCubic: EasingFunction;
  easeOutCubic: EasingFunction;
  easeInOutCubic: EasingFunction;
  easeInQuart: EasingFunction;
  easeOutQuart: EasingFunction;
  easeInOutQuart: EasingFunction;
  easeInQuint: EasingFunction;
  easeOutQuint: EasingFunction;
  easeInOutQuint: EasingFunction;
  easeInSine: EasingFunction;
  easeOutSine: EasingFunction;
  easeInOutSine: EasingFunction;
  easeInExpo: EasingFunction;
  easeOutExpo: EasingFunction;
  easeInOutExpo: EasingFunction;
  easeInCirc: EasingFunction;
  easeOutCirc: EasingFunction;
  easeInOutCirc: EasingFunction;
  easeInBack: EasingFunction;
  easeOutBack: EasingFunction;
  easeInOutBack: EasingFunction;
  easeInElastic: EasingFunction;
  easeOutElastic: EasingFunction;
  easeInOutElastic: EasingFunction;
  easeInBounce: EasingFunction;
  easeOutBounce: EasingFunction;
  easeInOutBounce: EasingFunction;
}
