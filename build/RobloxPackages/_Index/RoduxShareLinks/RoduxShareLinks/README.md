# Share Links Reducer
A Rodux reducer for Share Links data

Part of the [Social Package Ecosystem](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438). Check out [this link](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438) for more information!

## Usage Guide
To use this repository, you'll first need to create an ShareLinksReducer instance.
```lua
local ShareLinksReducer = require(Packages.ShareLinksReducer)
local myShareLinksReducer = ShareLinksReducer.config({
	keyPath = "shareLinks",
})
```
### Configuration options
| Name      | Default | Description                                                                                     |
|-----------|---------|-------------------------------------------------------------------------------------------------|
| `keyPath` | 🚫      | **Required**. Tell the package where you call `installReducer()` in your application's reducer. |

You'll need to install the reducer into your application's reducer. Take special care to make sure the path to this reducer matches your `keyPath`. If using nested reducers, you may split the path with periods to indicate you're indexing a lower scope.

```lua
local reducer = Rodux.combineReducers({
	shareLinks = myShareLinksReducer.installReducer(),
	-- other reducers...
})
```

### Reducer Structure
```
> Invites: { ShareInviteLink: string }
```

#### Share Links - Enums

LinkType
| Name | Value |
|------|------|
| Unset | "Unset" |
| ExperienceInvite | "ExperienceInvite" |

LinkStatus
| Name | Value |
|------|------|
| Invalid | "Invalid" |

ExperienceInviteStatus
| Name | Value |
|------|------|
| Expired | "Expired" |
| InviterNotInExperience | "InviterNotInExperience" |
| Valid | "Valid" |

### Supported Actions
| Location                                                                            | Name                                             |
|-------------------------------------------------------------------------------------|--------------------------------------------------|
| InvitesReducer                                                                      | `SetShareInviteLink(url: string)`                |
| InvitesReducer                                                                      | `ClearShareInviteLink()`                         |
| [ShareLinksNetworking](https://github.com/Roblox/networking-sharelinks#implemented-endpoints) | `GenerateLink({ linkType: string })` |


## Contributing

See [this guide](https://confluence.rbx.com/display/SOCIAL/Working+With+Social+Packages) for how to contribute to this project. In particular cutting releases. For more specific information see [CONTRIBUTING](CONTRIBUTING.md).

### Versioning
Follow SemVar [guidelines](https://semver.org/).

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
Use [lest](http://www.github.com/roblox/lest) to run tests. Use `lest env list` to generate a list of available test suites.

```bash
lest
```


To run the linter via command line:
```
bin/run-lint.sh
```
