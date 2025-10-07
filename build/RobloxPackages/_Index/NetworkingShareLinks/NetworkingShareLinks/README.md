# ShareLinks Networking
A rodux-networking wrapper around Share Links AKA Generic Deep Links.

Part of the [Social Package Ecosystem](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438). Check out [this link](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438) for more information!

## Usage

In order to use this package, you'll first need to run `config` and pass in an implementation of RoduxNetworking as `roduxNetworking`.

```lua
local ShareLinksNetworking = require(...).config({
	roduxNetworking = myRoduxNetworking,
})
```

## Implemented Endpoints

| Name                   | Parameters     | Endpoint                                                                                                      | Example                                  |
| ---------------------- | -------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| GenerateLink   | linkType: string | [/v1/create-link](https://apis.simulprod.com/generic-deep-links-api/swagger/index.html)           | `dispatch(GenerateLink.API({ linkType = "ExperienceInvite"}))`  |
| ResolveLinkFromLinkId   | linkType: string, linkId: string, | [/v1/resolve-link](https://apis.simulprod.com/generic-deep-links-api/swagger/index.html)           | `dispatch(ResolveLinkFromLinkId.API({ linkType = "ExperienceInvite", linkId = "12345"}))`  |


* Can only see this if you're in office or 'Full Tunnel' VPN

## Working Example
See [this end to end test](tests/e2e/test.spec.lua) for a working example.

## Running project
### Setup
**Optional**: Install and run [foreman](https://github.com/roblox/foreman) (make sure you're on the VPN to install rotriever):
```
foreman install
```

Then install dependencies:
```
rotrieve install
```

### Tests
Use [lest](http://www.github.com/roblox/lest) to run tests. Use `lest env list` to generate a list of available test suites.

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

### Versioning
Follow SemVar [guidelines](https://semver.org/).

### Contributing:
See [this guide](https://confluence.rbx.com/display/SOCIAL/Working+With+Social+Packages) for how to contribute to this project. In particular cutting releases.

## Still have questions?
Be sure to check out the [RoduxNetworking](http://www.github.com/roblox/rodux-networking) documentation.
