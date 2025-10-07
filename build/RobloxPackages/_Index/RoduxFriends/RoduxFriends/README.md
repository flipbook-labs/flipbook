# THIS REPO HAS BEEN DEPRECATED. Future uses / modifications / updates should be made in the friends-rodux package in lua-apps instead.

# Friends Reducer
A Rodux reducer for Friends data

Part of the [Social Package Ecosystem](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438). Check out [this link](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438) for more information!

## Usage Guide
To use this repository, you'll first need to create an FriendsReducer instance.
```lua
local FriendsReducer = require(Packages.FriendsReducer)
local myFriendsReducer = FriendsReducer.config({
	keyPath = "friends",
})
```
### Configuration options
| Name      | Default | Description                                                                                     |
| --------- | ------- | ----------------------------------------------------------------------------------------------- |
| `keyPath` | 🚫       | **Required**. Tell the package where you call `installReducer()` in your application's reducer. |

You'll need to install the reducer into your application's reducer. Take special care to make sure the path to this reducer matches your `keyPath`. If using nested reducers, you may split the path with periods to indicate you're indexing a lower scope.

```lua
local reducer = Rodux.combineReducers({
	friends = myFriendsReducer.installReducer(),
	-- other reducers...
})
```

### Reducer Structure (v3)

```
> byUserId: { [userId: string]: { userIds: string } }
> countsByUserId: { [userId: string]: friendCount: number }
> requests: {
	receivedCount: number,
	byUserId: {[string]: boolean},
	mutualFriends: {[string]: {string}},
	sourceUniverseIds: {[string]: number},
	nextPageCursor: string?,
	sentAt: {[string]: DateTime},
	originSourceType = { [string] = string },
	senderNickname = {[string] = string},
}
> recommendations: {
	byUserId: { [localUserId: string]: { [recommendationId: string]: RecommendationModel } },
	bySource: { [source: string]: { [recommendationId: string]: boolean } }
	hasIncomingFriendRequest: { [recommendationId: string]: boolean } (can be part of friendshipStatus reducer, but kept separately to isolate experiment)
}
> friendshipStatus: { [userId: string]: Enum.FriendStatus }
> friendsRankByUserId: { [baseUserId: string]: { [userId: string]: rank: number } }
```

### Models

#### Recommendation
| Field       | Type    | Description                                                                                   |
|-------------|---------|-----------------------------------------------------------------------------------------------|
| id          | string  | A globally unique identifier given to the user's profile.                                     |
| mutualFriendsList | { string }? | A comprehensive list of [friend id's (or displayNames?)](https://github.com/Roblox/rodux-friends/issues/68) that the two users have in common |
| rank       | number  | Score for ordering recommendations. Lower is higher priority.                                     |
| contextType | RecommendationContextType | Reason for recommendation. This is an Enum which has values of `MutualFriends` or `None`  |
| mutualFriendsCount | number | Number of mutual friends that the two users have in common |

### Supported Actions (v3)
| Location                                                                                | Name                                                    |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| FriendsReducer                                                                          | `FriendshipCreated(userId1: string, userId2: string)`   |
| FriendsReducer                                                                          | `FriendshipDestroyed(userId1: string, userId2: string)` |
| FriendsReducer | `FriendRequestCreated(id: string, mutualFriends: {string}?, sourceUniverseId: number?)` |
| FriendsReducer | `FriendRequestDeclined(ids: {string})` |
| FriendsReducer | `RecommendationCreated({ baseUserId: string, recommendedUser: RecommendationModel })` |
| FriendsReducer | `RecommendationDestroyed({ baseUserId: string, recommendedUserId: string })` |
| FriendsReducer | `RequestReceivedCountUpdated(count: number)` |
| FriendsReducer | `RecommendationSourceCreated({ source: string, recommendationIds: { string | number } })` |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `GetFriendsFromUserId.API(userId: number, { userSort: string? }?)`              |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `GetFriendRequestsCount.API()`                          |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `GetFriendRequests.API({ fetchMutualFriends = false, sortOrder = "Desc", limit = 10, cursor = "", currentUserId = "123" })` |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `AcceptFriendRequestFromUserId.API(currentUserId: number, targetUserId: number)` |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `DeclineFriendRequestFromUserId.API(currentUserId: number, targetUserId: number)` |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `DeclineAllFriendRequests.API()` |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `GetFriendRecommendationsFromUserId.API({ targetUserId = "123" })` |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `RequestFriendshipFromUserId.API({ currentUserId = 123, targetUserId = 456 })` |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `GetFriendshipStatus.API({ currentUserId = 123, targetUserIds = {456, 789} })` |
| [FriendsNetworking](https://github.com/roblox/friends-networking#implemented-endpoints) | `GetExtendedFriendshipStatus.API({ targetUserId = 123 })` |
| [NetworkingBlocking](https://github.com/Roblox/lua-app-networking/blob/main/modules/NetworkingBlocking/README.md) | `BlockUserById.API({ userId = "123", currentUserId = "456" })` |

### Selectors
| Name                                                   | Return Value    |
| ------------------------------------------------------ | --------------- |
| isFriendsWith(state, userId1: string, userId2: string) | result: boolean |
| getSortedByRankRecommendations(state, userId: string) | result: { [number]: RecommendationModel } |
| selectFriendshipStatusesByUserIds(state) ({ userIds: string }) | result: { [userId: string]: Enum.FriendStatus } |
| getRecommendationIdsBySource(state)(source: string) | result: { userIds: string } |
| getSortedByRankRecommendationIds(state)(currentUserId: string, { userIds: string }) | result: { userIds: string } |
| selectRecommendationsForUserId(state)(currentUserId: string, { userIds: string }) | result: { [userId: string]: RecommendationModel } |

### Enums
| Name                                                   | Details | Values   |
| --------------------------- | ---------  | --------------- |
| RecommendationContextType | The reason for a recommendation  | `None` or `MutualFriends` or `Frequents` |

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
