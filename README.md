# Pronto iOS SDK

_The official Pronto iOS SDK_

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](http://cocoadocs.org/docsets/Natrium) 
[![Documented](documentation/badge.svg)](documentation/index.html)
[![Travis-ci](https://travis-ci.com/Pronto-am/MobileCMS-iOS-SDK.svg?branch=master)](https://travis-ci.com/Pronto-am/MobileCMS-iOS-SDK)

## Installation

### Cococapods

Add the following to your Podfile:

```ruby
pod 'ProntoSDK', :git => 'https://github.com/Pronto-am/MobileCMS-iOS-SDK.git'
```

**Available sub-specs:**

- `ProntoSDK/Authentication`
- `ProntoSDK/Notifications`
- `ProntoSDK/Collections`

And run:

```shell
pod install
```

## Implementation

### Core

In `AppDelegate.swift`:

```swift
import ProntoSDK

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    let config = ProntoConfig()
    
    // Setup the API client credentials
    config.clientID = "<CLIENT_ID>"
    config.clientSecret = "<CLIENT_SECRET>"
    config.encryptionKey = "<ENCRYPTION_KEY>"
    
     // Activate each plugin your project uses
    config.plugins = [ .notifications, .authentication, .collections ]
    
    // For staging environment:
//  config.domain = "prontocms.e-staging.nl"
//  config.firebaseDomain = "pronto-staging.firebaseio.com"
    
    // Disable logging for non-debug builds
    #if DEBUG
        config.logger = Logger()
    #endif
    
    ProntoSDK.configure(config)
    
    // Do the rest of the implementation
    
    return true
```

### Notifications plugin

 → 📯  [Read notifications documentation](docs/NOTIFICATIONS.md)

### Authentication plugin

 → 🔐 [Read authentication documentation](docs/AUTHENTICATION.md)

### Collections plugin

 → 🗂 [Read collections documentation](docs/COLLECTIONS.md)

## Promises

Almost every asynchronous function ProntoSDK uses `Promises` internally:

```swift
let collection = ProntoCollection<Location>()
collection.list().then { result in
    // ...
}.catch { error in 
    print("Error fetching locations: \(error)")
}
```

If you want to convert it to your own handler [read the promises guide](docs/PROMISES.md).