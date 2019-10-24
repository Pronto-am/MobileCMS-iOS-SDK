# Remote config

This plugin will allow the user to set remote config keys and values.

## Implementation

### Initialization

```swift
let remoteConfig = ProntoRemoteConfig()
```

### Fetching

```swift
remoteConfig.fetch()
```

or

```swift
remoteConfig.fetch { items in 
	// items: [RemoteConfigItem]
}
```


### Reading

```swift
let item = remoteConfig.get("bannering_enabled") // RemoteConfigItem
item.boolValue // true
```

All of them

```swift
remoteConfig.items
```