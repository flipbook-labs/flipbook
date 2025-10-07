# Games Reducer
A Rodux reducer for Games data

 Part of the [Social Package Ecosystem](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438). Check out [this link](https://confluence.rbx.com/pages/viewpage.action?pageId=244706438) for more information!

## Usage Guide
To use this repository, you'll first need to create an GamesReducer instance.
```lua
local RoduxGames = require(Packages.RoduxGames)
local myGamesReducer = RoduxGames.config({
	keyPath = "games",
})
```
### Configuration options
| Name      | Default | Description                                                                                     |
| --------- | ------- | ----------------------------------------------------------------------------------------------- |
| `keyPath` | 🚫       | **Required**. Tell the package where you call `installReducer()` in your application's reducer. |

You'll need to install the reducer into your application's reducer. Take special care to make sure the path to this reducer matches your `keyPath`. If using nested reducers, you may split the path with periods to indicate you're indexing a lower scope.

```lua
local reducer = Rodux.combineReducers({
	games = myGamesReducer.installReducer(),
	-- other reducers...
})
```

### Terminology
Games terminology can be very confusing. For the sake of simplicity, we will define the terminologies we will use in this library:
| Term         | AKA      | Definition                                                                                                  |
|--------------|----------|-------------------------------------------------------------------------------------------------------------|
| Game         | Universe | The main identity of a Game. These are comprised of Places.                                                 |
| Place        | Level    | The specific sub-Place in a Game. This can be the root Place or a non-root Place.                           |
| GameInstance | Job      | The specific RCC server any particular user is connected to. There can be multiple GameInstances per Place. |


### Reducer Structure

```
> playabilityByGameId: { gameId: string = playabilityEnum }
> byGameId: { gameId: string = gameModel }
> productInfoByGameId: { gameId: string = productModel }
> mediaByGameId: { gameId: string = [gameMediaModel] }
> TODO: byGameInstanceId: { gameInstanceId: string = gameIds: { string } }
> TODO: byPlaceId: { placeId: string = gameIds: { string } }
```

### Supported Actions
| Location                                                                                | Name                                                    |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| [NetworkingGames](https://github.com/Roblox/networking-games) | `GetExperiencesPlayabilityStatus.API({ [number]: string(universeIds) })`              |
| [NetworkingGames](https://github.com/Roblox/networking-games) | `GetExperiencesDetails.API({ [number]: string(universeIds) })`              |
| [NetworkingGames](https://github.com/Roblox/networking-games) | `GetExperiencesProductInfo.API({ [number]: string(universeIds) })`              |
| [NetworkingGames](https://github.com/Roblox/networking-games) | `GetExperienceMedia.API({ universeId: number })`              |

### Models

GameModel
| Field | Type | Definition |
|-------|------|------------|
| gameId | string | Identifier for the Game |
| rootPlaceId | string | Identifier for the root Place |
| name | string | The Game name |
| description | string | The Game description |
| creator | Creator | The Game creator |
| price | number | The Game price if Paid Access is enabled |
| maxPlayers | number | The server limit |
| playing | number | The number of users currently playing |

CreatorModel
| Field | Type | Definition |
|-------|------|------------|
| creatorId | string | Identifier for the Creator. Can be a groupId or userId |
| creatorType | CreatorTypeEnum | User or Group |
| creatorName | string | The name of the creator |

ProductModel
| Field | Type | Definition |
|-------|------|------------|
| productId | string | Identifier for the Product |
| sellerId | string | Identifier for the Seller |
| price | number | The Product price if isForSale |
| isForSale | boolean | If product is for sale (Paid Access status for games) |

GameMediaModel
| Field | Type | Definition |
|-------|------|------------|
| assetTypeId | number | Identifier of the asset type |
| assetType | string | Name of the asset type |
| imageId | number | The id for images types |
| videoHash | string | The hash for video types |
| videoTitle | string | The title for video types |
| approved | boolean | Whether the media is approved |
| altText | string | Alternate text fort the asset type |

### Enums

CreatorType
| Name | Value |
|------|------|
| User | "User" |
| Group | "Group" |

Playability
| Name | Value |
|------|------|
| Playable | "Playable" |
| UnplayableOtherReason | "UnplayableOtherReason" |
| GuestProhibited | "GuestProhibited" |
| GameUnapproved | "GameUnapproved" |
| IncorrectConfiguration | "IncorrectConfiguration" |
| UniverseRootPlaceIsPrivate | "UniverseRootPlaceIsPrivate" |
| InsufficientPermissionFriendsOnly | "InsufficientPermissionFriendsOnly" |
| InsufficientPermissionGroupOnly | "InsufficientPermissionGroupOnly" |
| DeviceRestricted | "DeviceRestricted" |
| UnderReview | "UnderReview" |
| PurchaseRequired | "PurchaseRequired" |
| AccountRestricted | "AccountRestricted" |
| TemporarilyUnavailable | "TemporarilyUnavailable" |


### Selectors

## Contributing

See [this guide](https://confluence.rbx.com/display/SOCIAL/Working+With+Social+Packages) for how to contribute to this project. In particular cutting releases.

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
To run all tests via the command line:
```
lest
```

To run a subset of the tests pass a test filter pattern to `lest` via the `-t` parameter:

```
lest -t "Test Filter Pattern"
```
