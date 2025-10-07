# Changelog

## Unreleased

## 2.0.0 (July 30, 2023)
* Switched react-spring's react and reactroblox scopes from corepackages to jsdotlua ([@vocksel](https://github.com/vocksel) in [#51](https://github.com/chriscerie/roact-spring/pull/51))

## 1.1.6 (June 7, 2023)
* Fixed incorrect easing functions for easeInExpo, easeOutExpo, easeInOutCirc, easeInElastic, and easeOutElastic. This is potentially breaking if you relied on the incorrect easing behavior ([@passhley](https://github.com/passhley) in [#49](https://github.com/chriscerie/roact-spring/pull/49))
* Added easing easeInOutElastic ([@passhley](https://github.com/passhley) in [#49](https://github.com/chriscerie/roact-spring/pull/49))

## 1.1.5 (April 23, 2023)
* Fixed an issue where the spring would never finish if precision is too low

## 1.1.4 (April 22, 2023)
* Fixed luau typings ([@chriscerie](https://github.com/chriscerie) in [#42](https://github.com/chriscerie/roact-spring/pull/42))
* Fixed controller using dot operator for rbxts ([@chriscerie](https://github.com/chriscerie) in [#45](https://github.com/chriscerie/roact-spring/pull/45))
* Added roact and roact-hooks as peerDependencies for rbxts ([@chriscerie](https://github.com/chriscerie) in [#46](https://github.com/chriscerie/roact-spring/pull/46))
* Fixed `isRoact17` require for rbxts users

## 1.1.3 (Jan 20, 2023)
* Fixed roblox-ts typings ([Xuleos](https://github.com/Xuleos) in [#29](https://github.com/chriscerie/roact-spring/pull/29))
* Fixed roblox-ts false positives when running plugins on roblox-ts games ([sasial-dev](https://github.com/sasial-dev) in [#40](https://github.com/chriscerie/roact-spring/pull/40))

## 1.1.2 (Nov 29, 2022)
* Fixed `reset` prop not properly resetting velocity, previously yielding really fast springs in certain cases ([@chriscerie](https://github.com/chriscerie) in [#36](https://github.com/chriscerie/roact-spring/pull/36))

## 1.1.1 (Nov 5, 2022)
* Fixed `error` when passing reset = true without using from prop ([@chriscerie](https://github.com/chriscerie) in [#28](https://github.com/chriscerie/roact-spring/pull/28))
* Fixed `error` when passing from prop without including all keys ([@chriscerie](https://github.com/chriscerie) in [#28](https://github.com/chriscerie/roact-spring/pull/28))
* Fixed `useTrail` not returning promises on api.start ([@rwilliaise](https://github.com/rwilliaise) in [#33](https://github.com/chriscerie/roact-spring/pull/33))
* Added support for Roact17 ([@chriscerie](https://github.com/chriscerie) in [#35](https://github.com/chriscerie/roact-spring/pull/35))

## 1.0.1 (May 26, 2022)
* Fixed documentation incorrectly using dot operator for controllers
* Fixed `from` prop during imperative updates ([@lopi-py](https://github.com/lopi-py) in [#22](https://github.com/chriscerie/roact-spring/pull/22))
* Added Additional Notes section to docs

## 1.0.0 (April 21, 2022)
* Bumped promise version to v4.0 ([@chriscerie](https://github.com/chriscerie) in [#20](https://github.com/chriscerie/roact-spring/pull/20))
* Bumped roact-hooks version to v0.4 ([@chriscerie](https://github.com/chriscerie) in [#20](https://github.com/chriscerie/roact-spring/pull/20))
* Fixed calculations not responding to fps differences ([@chriscerie](https://github.com/chriscerie) in [#20](https://github.com/chriscerie/roact-spring/pull/20))

## 0.3.1 (March 29, 2022)
* Fixed an issue where duration-based anims would always start from the same position

## 0.3.0 (March 29, 2022)

* Removed implementation detail from return table
* Added `getting started` page to documentation
* Added `reset` prop ([@chriscerie](https://github.com/chriscerie) in [#17](https://github.com/chriscerie/roact-spring/pull/17))
* Added `loop` and `default` props ([@chriscerie](https://github.com/chriscerie) in [#18](https://github.com/chriscerie/roact-spring/pull/18))

## 0.2.3 (Feburary 20, 2022)

* Updated npm metadata
* Fixed library requires from packages

## 0.2.2 (Feburary 19, 2022)

* Added `progress` config for easing animations ([@chriscerie](https://github.com/chriscerie) in [#13](https://github.com/chriscerie/roact-spring/pull/13))
* Hooks now cancel animations when they are unmounted
* Added staggered text story to demos
* Fixed useSprings not removing unused springs when length arg decreases
* Added tests for `useSpring` and `useSprings`
* Added rbxts typings

## 0.2.1 (Feburary 17, 2022)

* Fixed `useTrail` delaying the wrong amount for varying delay times
* Fixed typo in docs

## 0.2.0 (Feburary 11, 2022)

* Fixed color3 animating with wrong values
* Cleaned up all stories to use circle button component
* Added support for hex color strings ([@chriscerie](https://github.com/chriscerie) in [#6](https://github.com/chriscerie/roact-spring/pull/6))
* Added motivation in docs
* Added `delay` prop
* Added `useTrail`
* Added optional dependency array to hooks

## 0.1.1 (February 3, 2022)

* Added `useSpring`
* Added `useSprings`
* Added `Controller`
* Added `SpringValue`
* Added `config`
* Added `easings`