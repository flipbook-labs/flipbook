# Alias Reducer
A Rodux reducer for Alias data

Part of the [Social Package Ecosystem](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438). Check out [this link](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438) for more information!

## Usage Guide
To use this repository, you'll first need to create an AliasReducer instance.
```lua
local AliasReducer = require(Packages.AliasReducer)
local myAliasReducer = AliasReducer.config({
	keyPath = "alias",
})
```
### Configuration options
| Name      | Default | Description                                                                                     |
|-----------|---------|-------------------------------------------------------------------------------------------------|
| `keyPath` | 🚫      | **Required**. Tell the package where you call `installReducer()` in your application's reducer. |

You'll need to install the reducer into your application's reducer. Take special care to make sure the path to this reducer matches your `keyPath`. If using nested reducers, you may split the path with periods to indicate you're indexing a lower scope.

```lua
local reducer = Rodux.combineReducers({
	alias = myAliasReducer.installReducer(),
	-- other reducers...
})
```

### Reducer Structure
```
> byUserId: {
	userId: string = alias: string,
	ShowUserId: string = showUserId: boolean,
}
```


### Supported Actions
| Location                                                                            | Name                                     | |
|-------------------------------------------------------------------------------------|------------------------------------------|------------------------------------------|
| AliasReducer                                                                        | `AliasUpdated(userId, newAlias)`         |
| AliasReducer                                                                        | `AliasRemoved(userId)`                   |
| AliasReducer                                                                        | `ReceivedCanShowUserAlias(showUserAlias)`|
| [AliasNetworking](https://github.com/Roblox/lua-app-networking/tree/main/modules/NetworkingAliases#implemented-endpoints) | `GetTagsFromUserIds.API(userIds)`        |
| [AliasNetworking](https://github.com/Roblox/lua-app-networking/tree/main/modules/NetworkingAliases#implemented-endpoints) | `SetUserTag.API(userId, alias)`        |

### Selectors
| Name                                    | Return Value  |
|-----------------------------------------|---------------|
| getAliasByUserId(state, userId: string) | alias: string |

## Contributing

See [this guide](https://confluence.rbx.com/display/SOCIAL/Working+With+Social+Packages) for how to contribute to this project. In particular cutting releases. For more specific information see [CONTRIBUTING](CONTRIBUTING.md).
## Setup
**Optional**: Install and run [foreman](https://github.com/roblox/foreman) (make sure you're on the VPN to install rotriever):
```
foreman install
```

Then install dependencies:
```
rotrieve install
```

## Tests
To run all tests via the command line:
```
lest
```

To run a subset of the tests pass a test filter pattern to `lest` via the `-t` parameter:

```
lest -t "Test Filter Pattern"
```

To run the linter via command line:
```
bin/run-lint.sh
```
