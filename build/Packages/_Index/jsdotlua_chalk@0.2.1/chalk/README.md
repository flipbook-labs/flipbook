# Chalk-Lua

A Lua port of the open source JS terminal string styling library [Chalk](https://github.com/chalk/chalk).

<img src="https://cdn.jsdelivr.net/gh/chalk/ansi-styles@8261697c95bf34b6c7767e2cbe9941a851d59385/screenshot.svg" width="900">

---

## Installation

Add this package to your `[dependencies]` in your `rotriever.toml`.
```
Chalk = "github.com/roblox/chalk-lua@0.2.0"
```

Run `rotrieve install` to install the package.

Require it at the top of your file.
```lua
local chalk = require(Packages.Chalk)
```

---

## API

`chalk.style(string)` to style a `string` (or `tostring`-able object) with any of the following modifiers, colors or color models.

### Modifiers

* `reset` - Resets the current color chain.
* `bold` - Make text bold.
* `dim` - Emitting only a small amount of light.
* `italic` - Make text italic. *(Not widely supported)*
* `underline` - Make text underline. *(Not widely supported)*
* `inverse`- Inverse background and foreground colors.
* `hidden` - Prints the text, but makes it invisible.
* `strikethrough` - Puts a horizontal line through the center of the text. *(Not widely supported)*

### Colors

* `black`
* `red`
* `green`
* `yellow`
* `blue`
* `magenta`
* `cyan`
* `white`
* `blackBright` (alias: `gray`, `grey`)
* `redBright`
* `greenBright`
* `yellowBright`
* `blueBright`
* `magentaBright`
* `cyanBright`
* `whiteBright`

### Background colors

* `bgBlack`
* `bgRed`
* `bgGreen`
* `bgYellow`
* `bgBlue`
* `bgMagenta`
* `bgCyan`
* `bgWhite`
* `bgBlackBright` (alias: `bgGray`, `bgGrey`)
* `bgRedBright`
* `bgGreenBright`
* `bgYellowBright`
* `bgBlueBright`
* `bgMagentaBright`
* `bgCyanBright`
* `bgWhiteBright`

Styles can be nested to apply multiple styles at the same time.
```lua
chalk.red(chalk.bold('red and bold'))
```
Later styles take precedence in case of a conflict (multiple nested styles of the same type). For example, `chalk.red(chalk.blue(chalk.green('green')))` will output green text.

Styles can be concatenated with `..` to be composed and stored.
```lua
local errorMessage = chalk.red..chalk.bold
errorMessage('red and bold')
```

The following color models can also be used:
```lua
-- accepts ANSI16 color codes
chalk.ansi(31)('red') -- valid values: 30-37, 90-97
chalk.bgAnsi(41)('bgRed') -- valid values: 40-47, 100-107

-- accepts ANSI256 color codes 
chalk.ansi256(196)('#ff0000') -- valid values: 0-255
chalk.bgAnsi256(196)('#ff0000') -- valid values: 0-255

-- downsamples to a valid ANSI256 color
chalk.rgb(255, 0, 0)('#ff0000')
chalk.bgRgb(255, 0, 0)('#ff0000')

chalk.hex('#ff0000')('red')
chalk.bgHex('#ff0000')('red')
```

`chalk.level` specifies the level of color support. This can be set by setting `chalk.level` to a different value, for example, `chalk.level = 0` to disable color support. Note that this will affect all uses of `chalk` throughout the entire module. The default value is 2. The flag `NOCOLOR` can be set with `--lua.globals=NOCOLOR=true` to set the default value to 0.
| Level | Description |
| :---: | :--- |
| `0` | All colors disabled |
| `2` | 256 color support |

---

## Unsupported features

* `chalk.level` - only suppors either level 2 or level 0
    * No automatic detection of terminal color support
    * Level 3 isn't supported so `rgb` and `hex` will downsample to the closest ANSI256 color
    * Level 1 isn't supported so color models with ANSI256 support (`ansi256`, `rgb`, `hex`) will never downsample to ANSI16
* The following color models:
    * `chalk.keyword`
    * `chalk.hsl`
    * `chalk.hsv`
    * `chalk.hwb`
* Can't method chain styles together like JS chalk, prefer to nest them instead. If they need to be composed together to be stored, use the concatenation (`..`) operator.
```lua
-- chalk.red.bold('foo')
chalk.red(chalk.bold('foo'))

-- const errorMessage = chalk.red.bold
local errorMessage = chalk.red..chalk.bold
```
* Can't nest styles of the same "type" (foreground or background color), prefer to split them up. Styles of different types can be nested, however, still prefer to split them up for consistency.
```lua
-- chalk.blue('blue' + chalk.red('red') + 'blue')
chalk.blue('blue' .. chalk.red('red') .. 'not blue')
chalk.blue('blue') .. chalk.red('red') .. chalk.blue('blue')
```
