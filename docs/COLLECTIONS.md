# Collections


## Implementation

First create a model that implements `ProntoCollectionMappable`:

```swift
class Location: ProntoCollectionMappable {
    enum LocationType: String {
        case store
        case headquarters = "hq"
    }

    static var collectionName: String {
        return "location"
    }

	 // Required variables
    var id = ""
    var createDate = Date()
    var updateDate = Date()
    
    // Custom variables
    var type: LocationType?
    var name: Text?
    var coordinate: Coordinate?    
    var related: [Location] = []

    required init(mapper: ProntoCollectionMapper) throws {
        try mapper.map(key: "name", to: &name)
        try mapper.map(key: "coordinate", to: &coordinate)
        try mapper.map(key: "type", to: &type)
        try mapper.map(key: "related", to: &related)
    }
}
```

A small rundown:

- `static var collectionName`: Tells the SDK to which collection identifier this collection type belongs
- Required variables `id`, `createDate` and `updateDate` are required properties of any pronto collection
- `required init(mapper: ProntoCollectionMapper) throws`: Will be called to parse / map the response from the api call

### Mapping options


`mapper.map(key:, to:)` maps a set property to the json value.
The following objects either implement the `ProntoCollectionMapValue` protocol or are mappable by itself:

- `Int`
- `Bool`
- `Float`
- `String`
- `Date`
- `Text`
- `TextURL`
- `Coordinate`
- `[String: Any]`
- `[Any]`
- `enum` objects that implement `RawRepresentable`
- Other objects that implement `ProntoCollectionMappable`


## Retrieval

### List
To receive a list of collection entries:

```swift
let collection = ProntoCollection<Location>()
collection.list().then { result in
    // result -> PaginatedResult
    // result.pagination -> Pagination
    // result.items -> [Location]
}.catch { error in 
	print("Error fetching locations: \(error)")
}
```

#### Pagination

```swift
let collection = ProntoCollection<Location>()
let pagination = Pagination(offset: 1, limit: 12) // This will get the 12 - 24th items
collection.list(pagination: pagination)
```

#### Sorting

```swift
let collection = ProntoCollection<Location>()
let pagination = Pagination(offset: 1, limit: 12) // This will get the 12 - 24th items
let sorting = SortOrder(key: "name", direction: .ascending) // Sort A -> Z
collection.list(sortBy: sorting, pagination: pagination)
```

#### Filtering

If you want to filter your list on the API side.
For instance only show locations of the "store" type

```swift
let collection = ProntoCollection<Location>()
let sorting = SortOrder(key: "name", direction: .descending) // Sort Z -> A
let filter = [ "type": Location.LocationType.shop.rawValue ]
collection.list(sortBy: sorting, filterBy: filter)
```


## Relations

For instance if you have got the following collections defined in the CMS:

- **Team**
  - Name
-  **Player**
  - Name
  - Team

With the following team entries:

- Juventus
- Barcelona
- Manchester United

and the following player entries:

- Christiano Ronaldo (Juventus)
- Mario Mandžukić (Juventus)
- Lionel Messie (Barcelona)
- Paul Pogba (Manchester United)
- David de Gea (Manchester United)
- Marouane Fellaini (Manchester United)

The following code will get you all the teams:

```swift
let collection = ProntoCollection<Team>()
collection.list().then { // ... }
```

and if you want to get all the players for Juventus:

Use the team itself:

```swift
let team: Team // = Juventus Team
let collection = ProntoCollection<Player>()
collection.list(filterBy: [ "team": team ]).then { // ... }
```

That will result in the following GET: `/api/v1/collections/V1/player?team=0818a0f6-8e89-11e8-a639-005056010246`