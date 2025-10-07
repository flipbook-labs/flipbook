---
sidebar_position: 1
---

# Introduction

<b>roact-spring</b> is a modern spring-physics based animation library for Roact inspired by react-spring. Instead of fixed durations, it uses physical properties like mass and tension to enable fluid and natural animations.

This library represents a modern approach to animation. It is the perfect bridge between declarative and imperative animations. It takes the best of both worlds and packs them into one flexible library.

## Installation

### Wally

`roact-spring` has two packages to support [Roact17](https://github.com/grilme99/CorePackages) and [legacy Roact](https://github.com/Roblox/roact). It is important to install the correct package or you **will** encounter bugs. To install, add the latest version of roact-spring to your wally.toml:

#### With Roact17
```console
RoactSpring = "chriscerie/react-spring@<version>"
```

#### With legacy Roact
```console
RoactSpring = "chriscerie/roact-spring@<version>"
```

### roblox-ts

`roact-spring` is also available for roblox-ts projects. Install it with [npm](https://www.npmjs.com/package/@rbxts/roact-spring):
```console
npm i @rbxts/roact-spring
```

## Why springs and not durations

:::note
Motivation from [react-spring](https://react-spring.io/#why-springs-and-not-durations)
:::note

The principle you will be working with is called a `spring`, it *does not have a defined curve or a set duration*. In that it differs greatly from the animation you are probably used to. We think of animation in terms of time and curves, but that in itself causes most of the struggle we face when trying to make elements on the screen move naturally, because nothing in the real world moves like that.

<p align="center">
    <img src="https://i.imgur.com/7CCH51r.png" width="200" />
</p>

We are so used to time-based animation that we believe that struggle is normal, dealing with arbitrary curves, easings, time waterfalls, not to mention getting this all in sync. As Andy Matuschak (ex Apple UI-Kit developer) [expressed it once](https://twitter.com/andy_matuschak/status/566736015188963328): *Animation APIs parameterized by duration and curve are fundamentally opposed to continuous, fluid interactivity*.