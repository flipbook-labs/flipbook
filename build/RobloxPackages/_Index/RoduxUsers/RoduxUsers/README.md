# Users Reducer
A Rodux reducer for Users data

Part of the [Social Package Ecosystem](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438). Check out [this link](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438) for more information!

## Usage Guide
To use this repository, you'll first need to create an UsersReducer instance.
```lua
local UsersReducer = require(Packages.UsersReducer)
local myUsersReducer = UsersReducer.config({
	keyPath = "users",
})
```
### Configuration options
| Name      | Default | Description                                                                                     |
|-----------|---------|-------------------------------------------------------------------------------------------------|
| `keyPath` | 🚫      | **Required**. Tell the package where you call `installReducer()` in your application's reducer. |

You'll need to install the reducer into your application's reducer. Take special care to make sure the path to this reducer matches your `keyPath`. If using nested reducers, you may split the path with periods to indicate you're indexing a lower scope.

```lua
local reducer = Rodux.combineReducers({
	users = myUsersReducer.installReducer(),
	-- other reducers...
})
```

### Reducer Structure
```
> byUserId: { userId: string = user: [userModel](#User) }
> byUsername: { username: string = userId: string }
```

### Models
#### User
| Field            | Type    | Description                                                                                   |
|------------------|---------|-----------------------------------------------------------------------------------------------|
| id               | string  | A globally unique identifier given to the user's profile.                                     |
| username         | string  | A unique username associated with the user's profile.                                         |
| displayName      | string  | The user's non-unique displayName.                                                            |
| hasVerifiedBadge | boolean | The user's Verified Badge status.                                                             |
| created | string | The user's account creation date |


### Supported Actions
| Location                                                                            | Name                                             |
|-------------------------------------------------------------------------------------|--------------------------------------------------|
| UsersReducer                                                                        | `UserUpdated(user: [userModel](#User))`          |
| UsersReducer                                                                        | `UserRemoved(userId: string)`                    |
| [UsersNetworking](https://github.com/roblox/networking-users#implemented-endpoints) | `GetSkinnyUsersFromUserIds(userIds: { string or number })` |
| [UsersNetworking](https://github.com/roblox/networking-users#implemented-endpoints) | `GetUserV2FromUserId(userId: string or number)` |
| [FriendsNetworking](https://github.com/roblox/networking-friends#implemented-endpoints) | `GetFriendsFromUserId(userId: string or number)` |
| [FriendsNetworking](https://github.com/roblox/networking-friends#implemented-endpoints) | `GetFriendRequests(fetchMutualFriends: boolean?, sortOrder: string?, limit: number?, cursor: string?)` |
| [FriendsNetworking](https://github.com/roblox/networking-friends#implemented-endpoints) | `GetFriendRecommendationsFromUserId({ targetUserId: string or number })` |


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
Use [lest](http://www.github.com/roblox/lest) to run tests. Use `lest env list` to generate a list of available test suites.

```bash
lest
```


To run the linter via command line:
```
bin/run-lint.sh
```
