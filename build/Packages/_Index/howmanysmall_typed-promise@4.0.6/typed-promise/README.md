# RbxTypedPromise

This package wraps around [roblox-lua-promise](https://github.com/evaera/roblox-lua-promise) and
adds types.

## Installation

You can install this package on Wally.

```toml
[dependencies]
Promise = "lukadev-0/typed-promise@4.0.2"
```

### wally-package-types

To use the types provided by the package, you must use the [wally-package-types](https://github.com/JohnnyMorganz/wally-package-types)
tool after running `wally install`. You can install it using [Aftman](https://github.com/LPGHatGuy/aftman).

## Types

Due to certain limitations ([which might be loosened in the future](https://github.com/Roblox/luau/pull/86))
this package cannot provide full typings. Therefore, there are two types: `TypedPromise<T...>` and `Promise`.

Any method of Promise that returns a Promise, such as `:andThen` or `:catch` will return the `Promise` type
because of Luau limitations.

The constructors, like `Promise.new` or `Promise.try` are strictly typed and return a `TypedPromise<T...>`.

Make sure you run [wally-package-types](#wally-package-types) in order to access the types!
