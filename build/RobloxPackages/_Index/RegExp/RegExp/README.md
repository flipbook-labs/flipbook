# RegExp for Luau
A regular expression library for Luau. Adapted from a regex implementation by github user Blockzez (https://github.com/Blockzez).

## API
Create a regex with the `new` function:
`RegExp.new(pattern: string, flags: string) -> RegularExpression`

A resulting RegularExpression has the following methods:
* `RegularExpression:exec(str: string) -> Match`
* `RegularExpression:test(str: string) -> boolean`

The `Match` object resulting from `exec` has the following fields:
* `[1..n]` - The array potion of the `Match` object contains captured groups
* `n` - The length of the array of resulting captured groups
* `index` - The index in the original string where the match begins
* `input` - The original string passed into `exec`

### Flags
The following flags can be provided via the second argument to `RegExp.new`:
* "i" - ignoreCase
* "g" - global
* "m" - multiline